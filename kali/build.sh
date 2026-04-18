docker build -t kali-pentest .

docker run -d \
--name kali-pentest \
-p 2222:22 \
--cap-add=NET_ADMIN \
--cap-add=NET_RAW \
--cap-add=SYS_PTRACE \
--memory=2g
--cpus=2
-v pentest-data:/home/pentester
kali-pentest