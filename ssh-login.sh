#!/usr/bin/expect -f

# This script automates PAM SSH session logins, performs a set of commands and exits.
# Yes, I know, you are wondering, hello it's 2024, why don't you use pssh?
# Well, I worked in a specific client environment where engineers have to use recorded PAM SSH sessions
# which require responding to prompts (passphrase, reason, then wait for shell prompt)

# First we take a server list provided with a text file, and we parse it line by line.
# Then we loop through that list to spawn an ssh session via /usr/bin/expect.
# Expect then allows us to handle prompts, respond to them and once we finally get the shell prompt
# we can run a few commands that we need.

# Due to the nature of a PAM SSH session being slooooooow ... everything has to have exception handling.
# Most critical is the set timeout right before waiting for the shell prompt. You may need to adjust it
# for your environment.

# The KEX Algo options and hostKeyAlgorithms were there for compatibility reasons with old
# RHEL 5/6 hosts where sshd was not updated for quite a few years ....

# Future improvements:
# have passphrase and reason defined as variables.
# process list of commands from a file, similar to server list mechanism...

# Of course, this script can be used for scripting regular SSH sessions, but why, ...
# only use this when required, and the PAM SSH session nonsense it quite possibly the only use case!

# Author: Leo Stehlik, CuveeBits, 2024
# License: AGPL-3

# Get list of hosts
set f [open "./<your_server_list"]
set hosts [split [read $f] "\n"]
close $f

# Iterate over hosts
foreach host $hosts {
    # Start SSH session
    spawn ssh -o KexAlgorithms=diffie-hellman-group14-sha1 -oHostKeyAlgorithms=+ssh-dss -i ~/.ssh/id_rsa_pam_mfa <yourPAMuserID>@<yourPAMhostID>@$host.with.fqdn.if.required@pam.host.fqdn.in.your.environment

    # Wait for passphrase prompt
    expect {
        "Enter passphrase for key '~/.ssh/id_rsa_pam_mfa':" {
            send -- "<your_super_secret_passphrase>\n"
        }
        timeout {
            puts "Error: Passphrase prompt not received for $host"
            continue
        }
        eof {
            puts "Error: Connection closed prematurely for $host"
            continue
        }
    }

    # Wait for reason prompt
    expect {
        "You are required to specify a reason for this operation:" {
            send -- "your super secret reason why you log in to the system\n"
        }
        timeout {
            puts "Error: Reason prompt not received for $host"
            continue
        }
        eof {
            puts "Error: Connection closed prematurely for $host"
            continue
        }
    }

    # Wait for the shell prompt (generic regex for prompt)
    set timeout 20
    expect {
        -re {\$|%|#} {
            # Connection is ready, send the command, these are just example commands
            send -- "df -kh\n"
            send -- "ls -la / \n"
            send -- "exit\n"
        }
        timeout {
            puts "Error: Shell prompt not received for $host"
            continue
        }
        eof {
            puts "Error: Connection closed prematurely for $host"
            continue
        }
    }
    #Reset timeout
    set timeout -1

    # Wait for the command to complete
    expect eof
}
