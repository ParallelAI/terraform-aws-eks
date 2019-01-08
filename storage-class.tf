resource "local_file" "storage-class" {
  content  = "${data.template_file.storage-class.rendered}"
  filename = "${var.config_output_path}storage-class_${var.cluster_name}.yaml"
  count    = "${var.manage_storage_class ? 1 : 0}"
}

resource "null_resource" "create_storage_class" {
  depends_on = ["aws_eks_cluster.this"]

  provisioner "local-exec" {
    command     = "for i in {1..5}; do kubectl apply -f ${var.config_output_path}storage-class_${var.cluster_name}.yaml --kubeconfig ${var.config_output_path}kubeconfig_${var.cluster_name} && break || sleep 10; done"
    interpreter = ["${var.local_exec_interpreter}"]
  }

  triggers {
    config_map_rendered = "${data.template_file.storage-class.rendered}"
  }

  count = "${var.manage_storage_class ? 1 : 0}"
}
