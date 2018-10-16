provider "aws" {
  region                  = "us-west-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "terraform"
}

resource "aws_security_group" "zk-test" {
  name = "zk_test"
  description = "default VPC security group"

  # ssh access
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "zk" {
  ami = "ami-09328e706055f45ba"
  instance_type = "r3.large"
  key_name = "us-west-1-zk-test"
  security_groups = ["${aws_security_group.zk-test.name}"]
  tags {
    Name = "zk-baseline"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      # install build tools
      "sudo apt-get update",
      "sudo apt-get -y install autotools-dev",
      "sudo apt-get -y install libtool",
      "sudo apt-get -y install autoconf",
      "sudo apt-get -y install build-essential",
      "sudo apt-get -y install libcppunit-dev",
      # install s3cmd
      "sudo apt-get -y install s3cmd",
      # install java 8
      "sudo add-apt-repository --yes ppa:webupd8team/java",
      "sudo apt-get update",
      "echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections",
      "sudo apt-get -y install oracle-java8-installer",
      "export JAVA_HOME=/usr/lib/jvm/java-8-oracle",
      "sudo apt-get update",
      "echo $JAVA_HOME",
      # install ant
      "sudo apt-get -y install ant"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "git clone https://github.com/apache/zookeeper.git"
    ]
  }

  provisioner "file" {
    source      = "run-baseline.sh"
    destination = "~/run-baseline.sh"
  }
}
