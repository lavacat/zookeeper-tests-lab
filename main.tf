provider "aws" {
  region                  = "us-west-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "terraform"
}

resource "aws_instance" "zk" {
  ami = "ami-09328e706055f45ba"
  instance_type = "m1.xlarge"
  tags {
    Name = "zk-baseline"
  }
    provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      # install s3cmd
      "sudo apt-get -y install s3cmd",
      # install java 8
      "sudo add-apt-repository ppa:webupd8team/java",
      "sudo apt-get update",
      "sudo apt-get -y install oracle-java8-installer",
      "export JAVA_HOME=/usr/lib/jvm/java-8-oracle",
      "sudo apt-get update",
      "echo $JAVA_HOME",
    ]
  }
}
