# puppet-globus
Configure Globus connect server and (optionally) Ceph connector.  

Before configuring globus you will need a globus ID: https://docs.globus.org/globus-connect-server-installation-guide/#globus_account_for_your_organization

Your Globus organization account credentials will be given to this module in params 'globus_user' and 'globus_password'.
 
After configuration with this module you will need to run 'globus-connect-server-setup' to initialize globus config files.  If you change the config later you will need to re-run the script.  In some managed configurations you may have cloned your endpoint to be managed by your organization - in this case coordinate with your local Globus admin before re-running the setup script because it will change your endpoint DN and require updating the node DN in your management console.  

Currently Globus does not require an endpoint to be cloned under your organization globus account to be managed.  It can just be added to the organization directly.  However some setups may still be using cloned endpoints to manage them.  For that reason the setup script does not run automatically on changes in case it would cause issues.    

## Dependencies

https://forge.puppet.com/puppetlabs/accounts

https://forge.puppet.com/puppetlabs/firewall  (if manage_firewall is true)

## Example

You must at a minimum configure the globus base class.  This is required even if using an alternate data connector.  

```
class { 'globus': 
    globus_user => 'youruser',
    globus_password => $globus_password,
    restrict_paths => 'RW/yourpath',
    enable_sharing => true,
    manage_firewall => true,  
    manage_repo => true  # default, only supported on redhat systems
}
```

To configure endpoint with Ceph connector (requires subscription and purchase of premium connector):

```
class { 'globus::ceph': 
    rgw_access_key => $rgw_access_key,
    rgw_secret_key => $rgw_secret_key,
    rgw_host => 'rgw.example.edu'
}
```

Configuring the Ceph connector disables local path sharing - the endpoint will only be usable for Ceph.

## More Information

This module has only been tested on RHEL7-type systems and no special consideration has been made for other distributions.  It may work if manage_repo is set to false.  

It is recommended that password information used in these classes be stored securely and not in plain-text in your manifest or hiera.  Hiera eyaml is a good option for this:

https://github.com/voxpupuli/hiera-eyaml

https://puppet.com/docs/puppet/5.5/hiera_config_yaml_5.html#configuring-a-hierarchy-level-hiera-eyaml

Globus Setup:  https://docs.globus.org/globus-connect-server-installation-guide/

Globus Ceph Connector:  https://docs.globus.org/premium-storage-connectors/ceph/
