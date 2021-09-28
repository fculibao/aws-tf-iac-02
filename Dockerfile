FROM ubuntu 
RUN apt-get update -y
RUN apt-get install –y nginx 
CMD [“echo”,”Image created”] 

