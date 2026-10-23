# Makefile for OS Mini Project (Terminal Snake Game & ASCII Digital Clock)

.PHONY: all run snake clock help clean

all: run

run:
	@chmod +x snake.sh clock.sh menu.sh
	@./menu.sh

snake:
	@chmod +x snake.sh
	@./snake.sh

clock:
	@chmod +x clock.sh
	@./clock.sh

clean:
	@rm -f snake_highscore .snake_highscore
	@echo "Cleaned high scores and temporary files."

help:
	@echo "OS Mini Project Suite"
	@echo "---------------------"
	@echo "make run   : Launch interactive project menu (default)"
	@echo "make snake : Launch Project 1 (Terminal Snake Game)"
	@echo "make clock : Launch Project 2 (ASCII Running Clock)"
	@echo "make clean : Reset local high scores and temporary files"
