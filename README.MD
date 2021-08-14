[![tfsec](https://github.com/noahkrohn/dreamhost-terraform/actions/workflows/tfsec-analysis.yml/badge.svg)](https://github.com/noahkrohn/dreamhost-terraform/actions/workflows/tfsec-analysis.yml)
# Introduction
There didn't seem to be a huge amount of information out there on how to leverage Terraform to manage infrastructure on Dreamhost so I decided to pull this together, hopefully it'll help other folks as well. I'm leveraging the following to accomplish this:

* Terraform v1.0.4
* provider registry.terraform.io/hashicorp/aws v3.54.0
* provider registry.terraform.io/terraform-provider-openstack/openstack v1.43.0

I'll offer two different ways to perform this. First I'll run you through doing this all from your own local system using the Terraform CLI. Second I'll show you how to do the same thing using GitHub actions. I'm partial to leveraging GitHub actions but it's totally up to you which you prefer. 

# Assumptions
Tech moves, shifts, and changes so I just wanted to note that this code repo represents a snapshot in time. It's possible pieces won't work in future versions of Terraform or with future versions of the openstack or aws modules. I tried to keep this as approachable as possible but you'll need some Linux knowhow to get going here. If you get stuck just shoot me a message and I'll do what I can to help you out. 

# Prerequisites
You'll obviously need a Dreamhost account for this. You'll also need a place to store your Terraform state. I'd recommend using a DreamObject for that just so you can keep everything in one place. It's interesting to note that while the DreamCompute setup leverages Openstack, DreamObject is Dreamhost's S3 implementation and thus needs to use that for the backend. To do that, sign-in to your account, click Cloud Services, then DreamObjects. Create a user and then an associated DreamObject. For instance I have my user created and a bucket called terraform. Click the user and copy both the access key and the secret key, you'll need them for access. 

# Coding Standard
Some folks won't include any variables associated with Terraform in their git repo. I like to split up my variables into those that contain privileged information and those that contain publicly-available information. For instance, you'd never want to include your access and secret key in your git repo, but showing you're leveraging us-east-1 isn't really going to shock anyone. So you'll find some of my variables are actually stored in my repo. As they won't let you do anything and won't let you get to any of my infrastructure, I'm comfortable storing them to make it easier for you to use this repo but will provide examples when you need to pass in your own . 

# Access Keys
There are a few ways to use your access keys. Storing them in a credentials file isn't how I personally would do it but if you're sure no one can get to your secrets file, then you do you. I prefer to export them as variables so once I exit my shell session, the information is gone. So assuming you've grabbed your access key and secret key, you'd run the following before starting (obviously replacing values with whatever yours are):
```bash
 export AWS_ACCESS_KEY_ID=<myaccesskey>
 export AWS_SECRET_ACCESS_KEY=<mysecretkey>
 export AWS_DEFAULT_REGION=us-east-1
```
Two things of note. First, in case it doesn't show up in the README well, I preface each of those lines with a space. I have my bash session set to not store history if the line starts with a space so I won't end up with the secrets in my bash history. If you don't do that, you might as well just store them in a credentials file if you trust your POSIX permissions. The other item of note is that you'll need to do this each time you start a new shell session as variables set like this won't persist after exit/logout. 

# Deploying Your Code
![This is where the fun begins](.github/fun.jpg)

## Using the Terraform CLI
### Terraform Init
You're all set now to initialize your backend and provider plugins, so now we get into where you'll be needing your own usernames, passwords, etc. 
```bash
 terraform init -backend-config="bucket=" \
  -backend-config="key=" \
  -backend-config="region=" \
  -backend-config="profile=" \
  -backend-config="endpoint="
```
After the equals sign on each of those lines you'll need to provide some information
* bucket is the S3 bucket you created from the steps above.
* key is the name of the directory and file your state will be saved to (e.g. if you want a directory to be created called 'PROD' and a file called terraform.tfstate then you would write "key=PROD/terraform.tfstate").
* region is the region of your bucket (e.g. us-east-1, us-west-2, etc.) so if you're looking at the Dreamhost display, just above your bucket you'll see a URL which can help you figure it out. So if it says objects-us-east-1.dream.io, you would write "region=us-east-1" (don't include the full URL). You'll need the full URL later so don't lose it. 
* profile is only needed if you're storing your key info in a file local to your system. If you followed my advice above and exported those values, you won't need this line but I'm including it just in case you decided I don't know what I'm talking about. 
* endpoint is where you'll need that full URL like I mentioned above under 'region.' Here you'll need the whole thing so if you're on us-west-2 then it'll be "endpoint=https://objects-us-west-2.dream.io "

If you did everything right you should get a pretty green output that "Terraform has been successfully initialized!" and now you're ready to run your plan. 

### Terraform Plan
Time to output a plan and make sure you like what you see. Same deal as above, I've created variables for anything I don't want checked into source control
```bash
 terraform plan -var 'user_name=' \
  -var 'password=' \
  -var 'tenant_name=' \
  -var 'tenant_id=' \
  -var 'auth_url=' \
  -var 'public_key=' \
  -var 'remote_ip_prefix=' \
  -var 'region=' \
  -out tfplan
```
* user_name is the username you use when you login to DreamCompute, not your regular Dreamhost login.
* password is the same deal as username, it's the password you use for DreamCompute.
* tenant_name is available once you're logged in to DreamCompute. Look in the upper left corner and you should see dhc followed by some digits.
* tenant_id is under Identity -> Projects and is listed as 'Project ID'. 
* auth_url is under Compute -> API Access. You'll use the full URL listed for 'Identity'.
* public_key is a valid OpenSSH public key. If you're naughty and reuse keys, feel free to seed with that otherwise create a new one here. 
* remote_ip_prefix is how I keep SSH access to my server locked down. I set this to be whatever my current external IP address is in full CIDR notation (e.g. if Comcast assigns an IP of 1.2.3.4 and a subnet of 255.255.255.0 to your cable modem then you'd set that to be 1.2.3.4/24 here)
* region is going to be the same as what you used above for the init

Once you run the plan it'll spew everything to screen and will also output your plan to the tfplpan file you specified. Assuming all goes well it'll also tell you what to do next.

### Terraform Apply
Now that you have a plan, all you need to do is run "terraform apply tfplan." You don't have to output your plan to a file but there's a method to that madness. If you're gearing up to or are currently working with CI/CD pipelines and are looking to adopt an immutable infrastructure stance, creating artifacts should be an absolute requirement. Outputting your plan also tells you exactly what will be performed and allows you to review that plan at a later date. You'll notice though that the gitignore for this repo doesn't allow for storage of the tfplan which is also intentional. Your tfplan contains sensitive data and shouldn't be stored in source control which will generally (hopefully) have looser role-based access than your artifact storage. When dealing with output plans - keep them secret, keep them safe. 

## Using GitHub Actions
Math teachers always teach the hard way first and I see no reason to break with that grand tradition. OK that's not entirely true. There are more moving parts in using GitHub actions, requires a little more knowledge than the CLI, and takes a little longer to get setup. However, it is also substantially more automated and maintainable. 

### Fork the Repo
You'll want to start with forking a copy of my repository so you can setup your own actions. Please note, at this time if you're on a free plan then you'll need your repository to be public in order to use GitHub actions so you'll need to keep yours public as well. 

### Create Your Secrets
Once you're in your own forked repository, go to Settings -> Environments and create a new environment. I called mine PROD as I'm partial to using the standard separation of development, staging, and production even if I'm working on small things like this. Add yourself as a required reviewer and then add the following secrets:
```bash
AUTH_URL
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
BUCKET
ENDPOINT
KEY
PASSWORD
PUBLIC_KEY
REGION
REMOTE_IP_PREFIX
TENANT_ID
TENANT_NAME
TF_API_TOKEN
USER_NAME
```
Set the values to be the same ones you used in the CLI example

### Action
GitHub will handily detect the actions already in the repo so you should have two there already - Terraform and tfsec. Both of these will run automatically when you push code to main. The Terraform action will create/modify/destroy your infrastructure as needed and the tfsec action will scan the repo for security issues. 

# Configuring the Web Server
TBD - need to create Ansible roles/playbooks