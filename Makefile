#==============================================================================#
#                                    NAMES                                     #
#==============================================================================#

NAME = inception
SRCS = ./srcs
COMPOSE = $(SRCS)/docker-compose.yml
HOST_URL = mmiguelo.42.fr

#==============================================================================#
#                                    RULES                                     #
#==============================================================================#

all: $(NAME)

$(NAME): up

# puts the url in the host files and starts the containers trough docker compose
up: create_dir
	@sudo hostsed add 127.0.0.1 $(HOST_URL) > $(HIDE) && echo " $(HOST_ADD)"
	@docker compose -p $(NAME) -f $(COMPOSE) up --build -d || (echo " $(FAIL)" && exit 1)
	@echo " $(UP)"

# stops and removes the containers, networks, volumes, and images created by up
down:
	@sudo hostsed rm 127.0.0.1 $(HOST_URL) > $(HIDE) && echo " $(HOST_RM)"
	@docker compose -p $(NAME) down
	@echo " $(DOWN)"

# creates the necessary directories for the services to run
create_dir:
	@mkdir -p ~/data/database
	@mkdir -p ~/data/wordpress_files
	@mkdir -p ~/data/portainer_data
	@mkdir -p ~/data/backups


# creates a backup of the data folder in the home directory
backup:
	@if [ -d ~/data ]; then sudo tar -czvf ~/data.tar.gz -C ~/ data/ > $(HIDE) && echo " $(BKP)" ; fi

# stop the containers, remove the volumes and remove the containers
clean:
	@docker compose -f $(COMPOSE) down -v
	@if [ -n "$$(docker ps -a --filter "name=nginx" -q)" ]; then docker rm -f nginx > $(HIDE) && echo " $(NX_CLN)" ; fi
	@if [ -n "$$(docker ps -a --filter "name=wordpress" -q)" ]; then docker rm -f wordpress > $(HIDE) && echo " $(WP_CLN)" ; fi
	@if [ -n "$$(docker ps -a --filter "name=mariadb" -q)" ]; then docker rm -f mariadb > $(HIDE) && echo " $(DB_CLN)" ; fi

# backups the data and removes the containers, images and the host url from the host file
fclean: clean backup
	@sudo rm -rf ~/data
	@if [ -n "$$(docker image ls $(NAME)-nginx -q)" ]; then docker image rm -f $(NAME)-nginx > $(HIDE) && echo " $(NX_FLN)" ; fi
	@if [ -n "$$(docker image ls $(NAME)-wordpress -q)" ]; then docker image rm -f $(NAME)-wordpress > $(HIDE) && echo " $(WP_FLN)" ; fi
	@if [ -n "$$(docker image ls $(NAME)-mariadb -q)" ]; then docker image rm -f $(NAME)-mariadb > $(HIDE) && echo " $(DB_FLN)" ; fi
	@sudo hostsed rm 127.0.0.1 $(HOST_URL) > $(HIDE) && echo " $(HOST_RM)"

status:
	@clear
	@echo "\nCONTAINERS\n"
	@docker ps -a
	@echo "\nIMAGES\n"
	@docker image ls
	@echo "\nVOLUMES\n"
	@docker volume ls
	@echo "\nNETWORKS\n"
	@docker network ls --filter "name=$(NAME)_all"
	@echo ""

# remove all containers, images, volumes and networks to start with a clean state
prepare:
	@echo "\nPreparing to start with a clean state..."
	@echo "\nCONTAINERS STOPPED\n"
	@if [ -n "$$(docker ps -qa)" ]; then docker stop $$(docker ps -qa) ;	fi
	@echo "\nCONTAINERS REMOVED\n"
	@if [ -n "$$(docker ps -qa)" ]; then docker rm $$(docker ps -qa) ; fi
	@echo "\nIMAGES REMOVED\n"
	@if [ -n "$$(docker images -qa)" ]; then docker rmi -f $$(docker images -qa) ; fi
	@echo "\nVOLUMES REMOVED\n"
	@if [ -n "$$(docker volume ls -q)" ]; then docker volume rm $$(docker volume ls -q) ; fi
	@echo "\nNETWORKS REMOVED\n"
	@if [ -n "$$(docker network ls -q) " ]; then docker network rm $$(docker network ls -q) 2> /dev/null || true ; fi 
	@echo ""

re: fclean all

# ───────── BONUS ─────────

# starts the bonus containers (includes host setup like 'up')
bonus: create_dir
	@sudo hostsed add 127.0.0.1 $(HOST_URL) > $(HIDE) && echo " $(HOST_ADD)"
	@docker compose -p $(NAME) -f $(COMPOSE) --profile bonus up --build -d || (echo " $(FAIL)" && exit 1)
	@echo " $(BONUS_UP)"

# stops and removes the bonus containers (includes host removal like 'down')
bonus-down:
	@sudo hostsed rm 127.0.0.1 $(HOST_URL) > $(HIDE) && echo " $(HOST_RM)"
	@docker compose -p $(NAME) -f $(COMPOSE) --profile bonus down
	@echo " $(BONUS_DOWN)"

# Customs ----------------------------------------------------------------------

HIDE		= /dev/null 2>&1

RED			= \033[0;31m
GREEN		= \033[0;32m
RESET		= \033[0m

MARK		= $(GREEN)✔$(RESET)
ADDED		= $(GREEN)Added$(RESET)
REMOVED		= $(GREEN)Removed$(RESET)
STARTED		= $(GREEN)Started$(RESET)
STOPPED		= $(GREEN)Stopped$(RESET)
CREATED		= $(GREEN)Created$(RESET)
EXECUTED	= $(GREEN)Executed$(RESET)

# Messages --------------------------------------------------------------------

UP			= $(MARK) $(NAME)		$(EXECUTED)
DOWN		= $(MARK) $(NAME)		$(STOPPED)
FAIL		= $(RED)✔$(RESET) $(NAME)		$(RED)Failed$(RESET)

HOST_ADD	= $(MARK) Host $(HOST_URL)		$(ADDED)
HOST_RM		= $(MARK) Host $(HOST_URL)		$(REMOVED)

NX_CLN		= $(MARK) Container nginx		$(REMOVED)
WP_CLN		= $(MARK) Container wordpress		$(REMOVED)
DB_CLN		= $(MARK) Container mariadb		$(REMOVED)

NX_FLN		= $(MARK) Image $(NAME)-nginx	$(REMOVED)
WP_FLN		= $(MARK) Image $(NAME)-wordpress	$(REMOVED)
DB_FLN		= $(MARK) Image $(NAME)-mariadb	$(REMOVED)

BKP			= $(MARK) Backup at $(HOME)	$(CREATED)

BONUS_UP	= $(MARK) $(NAME) bonus		$(EXECUTED)
BONUS_DOWN	= $(MARK) $(NAME) bonus		$(STOPPED)

# Phony -----------------------------------------------------------------------

.PHONY: all up down create_dir clean fclean status backup prepare re bonus bonus-down