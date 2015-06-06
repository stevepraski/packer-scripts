# packer-scripts

---
## Purpose:
Prepare a vagrant box based on existing Opscode vagrant base boxes, with recipes applied.

### Pain Point
When authoring cookbook recipes I found myself manually making new base vagrant boxes with applied finished recipes to save the extra converge time in test kitchen (e.g., compiling ruby from scratch, operating system updates, build tools, etc).  Unfortunately, but not unreasonably, Packer does not come with a built in Vagrant builder plugin.  Fortuanely, the VirtualBox builder plugin is completely workable.

### Solution
The included scripts will apply some recipes to a base box and spit out a re-packaged vagrant box which can be imported as a new base box for development.

### Suggested Extension
This repo can easily be forked and modified to spit out a prepared AMI with your own recipes by starting with existing standard operating system AMIs, using the appropriate Packer modules.  In theory, this could be integrated into your build pipeline to avoid the VPN (Virtual Private Network) bootstrap problem, although I'd suggest you still build the capability to run against a chef server.

---
## Usage

### Pre-Requisites
 - VirtualBox (https://www.virtualbox.org/wiki/Downloads)
 - Vagrant (https://www.vagrantup.com/)
 - Packer (https://www.packer.io/downloads.html)

### Repackaging a base vagrant box
```sh
cd vagrant
./repack.sh box-name cookbook-directory recipe
```
- Example

```sh
./repack.sh centos-6.5 ../../rails-box-cookbook rails-box-cookbook::default
```
- Notes:
You can use absolute or relative paths, but the script will also check 2 directory levels below what you specify, so in the above example just using "rails-box-cookbook" will work.


### Using the new prepared vagrant box
 - Add the box from the vagrant-repack-working directory

```sh
cd ../../vagrant-repack-working
vagrant box add <name-for-box> <prepped.box>
```
- Example:

```sh
cd ../../prep-box-cookbook-working directory
vagrant box add centos-6.5-prepped opscode-centos-6.5-prepped.box
```
 - create a ".kitchen.local.yml" and add section such as:

```yaml
platforms:
  - name: ubuntu-12.04
    driver:
      box: ubuntu-12.04-prepped
  - name: centos-6.5
    driver:
      box: centos-6.5-prepped
```

### Currently Supported Base Boxes
 - centos-6.5
 - ubuntu-12.04

---
## Other

### To Do List
 - replace the aggressive cleanup scripts from bento with custom cleanup scripts
 - possibly collapse the Packer json scripts, and workaround lack of curl on ubuntu-12.04
 - zero-out space prior to packing
 - 

### Credit and Thanks
 - thanks to opscode


### Licensing
The MIT License (MIT)

Copyright (c) 2015 Steven Praski

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---
