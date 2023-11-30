#!/bin/bash

########配置 RDS#########
# 创建 RDS Subnet Group
aws rds create-db-subnet-group \
    --db-subnet-group-name mydbsubnetgroup \
    --db-subnet-group-description "My DB subnet group" \
    --subnet-ids subnet-0b2a1b5b6515c7907 subnet-0f9d912306efdd1ff

# 创建 RDS MySQL 数据库实例,命名为 mydb,db.t2.micro 类型,用户名 admin,密码为 abc123
aws rds create-db-instance --db-instance-identifier mydb --engine mysql --db-instance-class db.r6g.large --master-username admin --master-user-password admin12345678 --allocated-storage 100 --db-subnet-group-name mydbsubnetgroup --vpc-security-group-ids sg-048fb75fba803e623

# 等待数据库实例创建完成并可用
aws rds wait db-instance-available --db-instance-identifier mydb
rdsedp=$(aws rds describe-db-instances --db-instance-identifier mydb --query 'DBInstances[*].Endpoint.Address' --output text)
echo "RDS Endpoint: $rdsedp"

# 安装客户端并执行ddl
echo "Y"|sudo yum install mysql 
mysql -h $rdsedp -u admin -padmin12345678 <./ddl.sql

########配置 AOS#########
aws opensearch create-domain   --domain-name domain66ac69e0-qliywzjucnoo --engine-version OpenSearch_2.3 --cluster-config InstanceType=r6g.xlarge.search,InstanceCount=2 --ebs-options EBSEnabled=true,VolumeType=gp2,VolumeSize=10 --access-policies '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"AWS":["*"]},"Action":["es:*"],"Resource":"*"}]}' --vpc-options SubnetIds=subnet-0b2a1b5b6515c7907,SecurityGroupIds=sg-048fb75fba803e623
aosedp=$(aws opensearch describe-domain --domain-name domain66ac69e0-qliywzjucnoo| jq -r '.DomainStatus.Endpoints.vpc')
echo "AOS Endpoint: $aosedp"
