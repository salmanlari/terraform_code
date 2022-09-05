output "dbhost" {

    value = aws_db_instance.wp-rds.address
} 
output "username" {
    value = aws_db_instance.wp-rds.username
  
}
output "password" {
  value = aws_db_instance.wp-rds.password
}
output "dbname" {
    value = aws_db_instance.wp-rds.db_name 
}