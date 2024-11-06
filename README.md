# ssh-scripted-login-when-PAM-ssh-connection-enforced

## When you need to go straight, but there are detours that you need to take in the environment you live in.

Imagine that in a normal world you would just generate your ssh keys, copy them over and use pssh. 

But then, you are in an environment where your rights to log-in directly via ssh session is no longer there. 

You have to use PAM conneciton string instead. Empty keyphrase not allowed, and you are prompted for
a reson why you connect to the particular machine. (Large enterprise environments, security by obscurity, many of us
been there...)

This script is your chance to respond to prompts using `/usr/bin/expect`

And process a list of servers. 

## So what it does? 

It takes a list of servers and parses it one by one into hosts variable. 
Then, for each host it spawns a ssh session (in sequence), using your id_rsa PAM key, and your fancy connection string...
Of course, you will have to modify the string to your requirements.

Then it responds to the passphrase prompt, error handling included. If it timeouts here, add some timeout if required.
We proceed to another prompt "Give us the reason why you connect to this system" enforced by PAM... only use this when you need it. 
Some PAM environments are configured so that they don't require mandatory reason ... 

Again, some error handling and now we wait for the shell prompt. 

In our environment, this took quite a while, anything between 15 - 20 seconds ...
The 20 sec timeout did it for us, however, you may need to adjust to your environment. 

Run your commands then in the same section, the ones there are just example, do whatever you need here. 

Again some error handling, and resetting the timout once we clear through this section. 

Once you reach EOF of your server list, you're done. 

## What next? 

We may add looping through a list of commands suppliend in a text file similar to what we do with server list. 
Also, we hardcoded here quite ugly the passphrase and reasons prompt responses, we could easily set them up as variables from a file too, but ... this one is probably just nice to have. 

## Can you use it for regular ssh sessions (non-PAM enforced recorded session madness}?

Sure you can, but why the efk would you want to do it to yourself? 
Only use such overcomplicated workarounds when and where you really need them! 

## Prerequisites

You need to have `expect` installed on your Linux/UNIX system. 
Example for an Ubuntu system with apt package manager: 

```
sudo apt update
sudo apt upgrade
sudo apt install expect
``` 

Or any other similar alternative install method depending on your Linux flavour. 

## Credits
(c) Leo Stehlik, CuveeBits, 2024

## License
AGPL-3
 
