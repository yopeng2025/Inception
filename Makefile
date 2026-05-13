NAME = inception
SRCS = ./srcs/docker-compose.yml
DATA_PATH = /home/yopeng/data

# Create necessary data directories before running containers
# -p = parent (create a directory if it does not exist)
# rwx r-x r-x
# -f = file+<filename>; up = run .yml
# -p = project name = inception
# -d = detached mode(run container in background)
# --build = build Docker image
all:				
	@sudo mkdir -p $(DATA_PATH)/mariadb
	@sudo mkdir -p $(DATA_PATH)/wordpress
	@sudo chmod 777 $(DATA_PATH)/mariadb
	@sudo chmod 777 $(DATA_PATH)/wordpress
	@sudo docker-compose -f $(SRCS) -p $(NAME) up -d --build

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
# -q = quiet (only show name, no other information)
# || true = do not report error exit
fclean: clean
	@sudo docker volume rm $$(sudo docker volume ls -q) || true
	@sudo rm -rf $(DATA_PATH)

re: fclean all

.PHONY: all stop down clean fclean re
