## <div style="color:orange;text-align:center;"> <p>Data Ingestion Pipeline</p> </div>

## <span style="color:blue"> <em>Table of Contents</em> </span>

1. [Design of the process](#Designoftheprocess)
2. [How to achive high availibity process](#availibityprocess)
3. [The Questions and Answers](#thequestionsandanswers)
4. [bottlenecks or problems ](#bottlenecksorproblems )

<a name="Designoftheprocess"></a>
## 1. High Level design of the process 
![High Level Design](./images/IngestionPipeline.JPG?raw=true)

<a name="availibityprocess"></a>
## 2. High Level design of the process 

Hosting application on EKS cluster would be the good solutions using the spot instances in the backend. This will bring Resilience in infrastructure and optimize cost. AWS Lambda will be used to drive the data using event driven architecture. Multiple lambda scripts are used for different segments. S3 acts as homeground for data where we dump any amount of data. The S3 should be configured with the intelligent tier to enable security, backups and availability. Cluster Autoscaler is an opensource tool used to scale EC2 instance automatically according to pods running in the cluster.

EC2 Auto scaler is AWS service group provisions and maintains EC2 instance capacity. AWS Node termination handler is an open source framework used to detec EC2 Spot interruptions and automatically drain nodes. The EKS nodes should be hosted atleast >4 availiability zones(AZs) to give more Spot capacity pools greatly increasing the stability and resilience of your application.

As the load grows, we scale up the nodes for the EKS cluster to consume more data in the peaks and scale down in the offset hours. This can be done by using multi-AZs with instances types to accommediate the pools capacity,

    Spot capacity pools = (Availability Zones) * (Instance Types)

<a name="thequestionsandanswers"></a>
## 3. The Questions and Answers

- The batch updates have started to become very large, but the requirements for their processing time are strict?
    - Escalator is an alternative for Cluster Autoscaler which is designed for large batch workloads that cannot be force-drained.
- Code updates need to be pushed out frequently. This needs to be done without the risk of stopping a data update already being processed, nor a data response being lost.
    - Parallelism of lambda step functions will help in mitigating the risk of stopping a data updates and lost of transactions. Consider increasing memory assigned to the function, Lambda can process up to 10 batches in each shard simultaneously.
- For development and staging purposes, you need to start up a number of scaled-down versions of the system.
    - Define a individual cluster for development and staging which can be run with scaled down versions of the system. This can be purely for Dev and testing with scheduled maintainance and limited backups.

<a name="bottlenecksorproblems"></a>
## 4. bottlenecks or problems

The data is a main challenge and how the data is coming plays a main role here. IF the data is in incremental loads, the system must be prepared according with all environment requirements, where in case the data is in a whole load it should be queued in pieces with certian load to run parallely on lambda functions. The queue should be watched/ monitored using cloudwatch for any lost events and aknowledgement is maintained.

Restructuring the infrastructure will be based on the load and time which are graphed and lambda functions with the time capacity. Parallalism can be a good strategy for handling uneven loads.



