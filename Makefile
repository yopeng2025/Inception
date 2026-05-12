NAME = inception
SRCS = ./srcs/docker-compose.yml
DATA_PATH = /home/yopeng/data								


# -f = file+<filename>; up = run .yml
# -d = detached mode(run container in background)
# --build = build Docker image
all: setup
	@sudo docker-compose -f $(SRCS) up -d --build				

# Create necessary data directories before running containers
# -p = parent (create a directory if it does not exist)
# rwx r-x r-x
setup:
	@sudo mkdir -p $(DATA_PATH)/mariadb							
	@sudo mkdir -p $(DATA_PATH)/wordpress
	@sudo chmod 755 $(DATA_PATH)/mariadb						
	@sudo chmod 755 $(DATA_PATH)/wordpress

# Stop containers
stop:
	@sudo docker-compose -f $(SRCS) stop						

# Down: Stop and remove containers, networks
down:
	@sudo docker-compose -f $(SRCS) down

# prune = cut off; -a = all(unused resources)
# delete images(unsused), containers(stopped), network(unused), cache; 
# DANGEEROUS in real environment!
clean: down
	@sudo docker system prune -a								

# Totally wipe out the persistent data from the host
# $$ = $ in shell;
# $$(sudo dcoker volume ls -q) = execute "$(docker volume ls -q)" in shell"
# || true = do not report error exit
fclean: clean													
	@sudo docker volume rm $$(sudo docker volume ls -q) || true 
	@sudo rm -rf $(DATA_PATH)
																
re: fclean all

.PHONY: all setup stop down clean fclean re
