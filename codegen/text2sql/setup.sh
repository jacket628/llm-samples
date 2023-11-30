#!/bin/bash

########创建database并导入sql#########
aws rds create-db-subnet-group \
    --db-subnet-group-name mydbsubnetgroup \
    --db-subnet-group-description "My DB subnet group" \
    --subnet-ids subnet-0b2a1b5b6515c7907 subnet-0f9d912306efdd1ff

# 创建 RDS MySQL 数据库实例,命名为 mydb,db.t2.micro 类型,用户名 admin,密码为 abc123
aws rds create-db-instance --db-instance-identifier llmnew2 --engine mysql --db-instance-class db.r6g.large --master-username admin --master-user-password admin12345678 --allocated-storage 100 --db-subnet-group-name mydbsubnetgroup --vpc-security-group-ids sg-048fb75fba803e623
# 等待数据库实例创建完成并可用
aws rds wait db-instance-available --db-instance-identifier llmnew2
endpoint=$(aws rds describe-db-instances --db-instance-identifier llmnew2 --query 'DBInstances[*].Endpoint.Address' --output text)
echo "Endpoint: $endpoint"

# 安装客户端并执行ddl
echo "Y"|sudo yum install mysql 
mysql -h $endpoint -u admin -padmin12345678 <./ddl.sql
