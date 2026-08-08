NAME = inception

COMPOSE = docker-compose -f srcs/docker-compose.yml

all:
	$(COMPOSE) up --build

clean:
	$(COMPOSE) down -v

fclean:
	$(COMPOSE) down -v --rmi all

re: fclean all

.PHONY: all clean fclean re