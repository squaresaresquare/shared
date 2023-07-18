#!/bin/bash
function expect_ipmi () {
    local host=$1
    local user=$2
    local pass=$3
    if [[ "$pass" != "" ]] && [[ "$user" != "" ]] && [[ "$host" != "" ]];then
    expect << EOF
    log_user 0
    spawn ssh -q -o StrictHostKeyChecking=no $user@$host
    expect {
        -re {assword:}
        {
            send "$pass\r"
        }
        -re {(%|#|>|\\$ )}
        {
            flush stdout
            send -- "sudo /usr/bin/ipmitool lan print 1 | grep 'IP Address' | grep -v 'Source' | awk '{print \\\$NF}'\r"
            expect {
                -re {(.sudo. password for $user: )} {
                    send "$pass\r"
                    expect {
                        -re {(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})} {
                            set bmc_ip \$expect_out(1,string)
                            puts "$host : \$bmc_ip"
                            send -- "logout\r"
                        }
                        -re {(No such file or directory)} {
                            puts "ipmi not set up on $host"
                            send -- "logout\r"
                        }
                        -re {(%|#|>|\\$ )} {
                            puts "command did not return an IP. Get the complete output" 
                            flush stdout
                            send -- "sudo /usr/bin/ipmitool lan print 1\r"
                            expect {
                                -re {(.sudo. password for $user: )} {
                                    send "$pass\r"
                                    expect {
                                        -re {(%|#|>|\\$ )} {
                                            puts "$host: command output"
                                            puts "\$expect_out(buffer)"
                                            send -- "logout\r"
                                        }
                                        timeout {
                                            puts "$host: timeout getting complete output"
                                            send -- "logout\r"
                                        }
                                    }
                                }
                                -re {(%|#|>|\\$ )} {
                                    puts "$host: command output"
                                    puts "\$expect_out(buffer)" 
                                    send -- "logout\r"
                                } 
                                timeout {
                                    puts "$host: timeout getting complete output"
                                    send -- "logout\r"
                                }
                            }
                        }
                        timeout
                        {
                            puts "$host: timeout waiting for IP\r"
                            send -- "logout\r"
                        }
                    }
                }
                -re {(No such file or directory)} {
                    puts "$host: ipmitool not set up on this host"
                    send -- "logout\r"
                }
                -re {(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})} {
                    set bmc_ip \$expect_out(1,string)
                    puts "$host : \$bmc_ip"
                    send -- "logout\r"
                }
                timeout
                {
                    puts "$host: timeout waiting for IP\r"
                    send -- "logout\r"
                }
            }
            send -- "logout\r"
        }
        timeout
        {
            puts "$host: timeout waiting for prompt or password\r"
            send -- "logout\r"
        }
        eof
        {
            puts "eof\r"
        }
    }
    expect {
        -re {(%|#|>|\\$ )}
        {
            flush stdout
            send -- "sudo /usr/bin/ipmitool lan print 1 | grep 'IP Address' | grep -v 'Source' | awk '{print \\\$NF}'\r"
            expect {
                -re {.sudo. password for $user: } {
                    send "$pass\r"
                    expect {
                        -re {(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})} {
                            set bmc_ip \$expect_out(1,string)
                            puts "$host : \$bmc_ip"
                            send -- "logout\r"
                        }
                        -re {(No such file or directory)} {
                            puts "$host: ipmitool not set up on this host"
                            send -- "logout\r"
                        }
                        -re {(%|#|>|\\$ )} {
                            puts "$host: command did not return an IP. Get the complete output"
                            flush stdout
                            send -- "sudo /usr/bin/ipmitool lan print 1\r"
                            expect {
                                -re {(.sudo. password for $user: )} {
                                    send "$pass\r"
                                    expect {
                                        -re {(%|#|>|\\$ )} {
                                            puts "\$expect_out(buffer)"
                                            send -- "logout\r"
                                        }
                                        timeout {
                                            puts "$host: timeout getting complete output"
                                            send -- "logout\r"
                                        }
                                    }

                                }
                                -re {(%|#|>|\\$ )} {
                                    puts "$host: command output"
                                    puts "\$expect_out(buffer)"
                                    send -- "logout\r"
                                }
                                timeout {
                                    puts "$host: timeout getting complete output"
                                    send -- "logout\r"
                                }
                            }
                        }
                        timeout
                        {
                            puts "timeout waiting for IP\r"
                            send -- "logout\r"
                        }
                    }
                }
                -re {(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})} {
                    set bmc_ip \$expect_out(1,string)
                    puts "$host : \$bmc_ip"
                    send -- "logout\r"
                }
                -re {(No such file or directory)} {
                    puts "$host: ipmitool not set up on this host"
                    send -- "logout\r"
                }
                -re {(%|#|>|\\$ )} {
                    puts "$host: command did not return an IP. Get the complete output"
                    flush stdout
                    send -- "sudo /usr/bin/ipmitool lan print 1\r"
                    expect {
                        -re {(.sudo. password for $user: )} {
                            send "$pass\r"
                            expect {
                                -re {(%|#|>|\\$ )} {
                                    puts "\$expect_out(buffer)"
                                    send -- "logout\r"
                                }
                                timeout {
                                    puts "$host: timeout getting complete output"
                                    send -- "logout\r"
                                }
                            }

                        }
 such file or directory)}
                        -re {(%|#|>|\\$ )} {
                            puts "$host: command output"
                            puts "\$expect_out(buffer)"
                            send -- "logout\r"
                        }
                        timeout {
                            puts "$host: timeout getting complete output"
                            send -- "logout\r"
                        }
                    }
                }
                timeout
                {
                    puts "$host: timeout waiting for IP\r"
                    send -- "logout\r"
                }
            }
        }
        timeout
        {
            puts "$host: timeout waiting for prompt\r"
            send -- "logout\r"
        }
        eof
        {
         puts "eof\r"
        }
   } 
EOF
    fi
}
default_file="test1"
default_user="${USER}"

file=$1
user=$2
file="${file:=$default_file}"
user="${user:=$default_user}"

#get password
read -s -t 60 -p "Enter ${user}'s password:" pass
echo
# populate array from file
declare -a hosts
hosts=($(cat $file))
hosts_length=${#hosts[@]}

#for each batch of hosts
for i in ${hosts[@]}
do
    expect_ipmi $i $user "$pass"
done
