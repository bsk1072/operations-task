resource "aws_key_pair" "development" {
  key_name   = "${var.ecs_cluster_name}_key_pair"
  public_key = file(var.ssh_pubkey_file)
}
