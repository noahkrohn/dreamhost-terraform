# Introduction
There didn't seem to be a huge amount of information out there on how to leverage Terraform to manage infrastructure on Dreamhost so I decided to pull this together, hopefully it'll help other folks as well. I'm leveraging the following to accomplish this:

Terraform v0.14.10
+ provider registry.terraform.io/hashicorp/aws v3.35.0
+ provider registry.terraform.io/terraform-provider-openstack/openstack v1.35.0

## Assumptions
Tech moves, shifts, and changes so I just wanted to note that this code repo represents a snapshot in time. It's possible pieces won't work in future versions of Terraform or with future versions of the openstack or aws modules.

## Prerequisites
You'll obviously need a Dreamhost account for this. You'll also need a place to store your Terraform state. I'd recommend using a DreamObject for that just so you can keep everything in one place. It's interesting to note that while the DreamCompute setup leverages Openstack, DreamObject is Dreamhost's S3 implementation and thus needs to use that for the backend. To do that, sign-in to your account, click Cloud Services, then DreamObjects. Create a user and then an associated DreamObject. For instance I have my user created and a bucket called terraform. Click the user and copy both the access key and the secret key, you'll need them for access. 

## Coding Standard
Some folks won't include any variables associated with Terraform in their git repo. I like to split up my variables into those that contain privileged information and those that contain publicly-available information. For instance, you'd never want to include your access and secret key in your git repo, but showing you're leveraging us-east-1 isn't really going to shock anyone. So you'll find some of my variables are actually stored in my repo. As they won't let you do anything and won't let you get to any of my infrastructure, I'm comfortable storing them to make it easier for you to use this repo. 

## Access Keys
There are a few ways to use your access keys. Storing them in a credentials file isn't how I personally would do it but if you're sure no one can get to your secrets file, then you do you. I prefer to export them as variables so once I exit my shell session, the information is gone. So assuming you've grabbed your access key and secret key, you'd run the following before starting (obviously replacing values with whatever yours are):
```bash
 export AWS_ACCESS_KEY_ID=<myaccesskey>
 export AWS_SECRET_ACCESS_KEY=<mysecretkey>
 export AWS_DEFAULT_REGION=us-east-1
```
Two things of note. First, in case it doesn't show up in the README well, I preface each of those lines with a space. I have my bash session set to not store history if the line starts with a space so I won't end up with the secrets in my bash history. If you don't do that, you might as well just store them in a credentials file. The other item of note is that you'll need to do this each time you start a new shell session as variables set like this won't persist after exit/logout. 