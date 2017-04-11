#include <stdio.h>
#include <stdbool.h>

#define WHITE 0xFFFF
#define BLACK 0x0000
#define RED 0xF800
#define BLUE 0x001F
#define UP 1
#define LEFT 2
#define DOWN 3
#define RIGHT 0

char direction;
int prevX, prevY;
int currentX, currentY;

void draw_pixel(int x, int y, short colour){
  volatile short *vga_addr=(volatile short*)(0x08000000 +(y<<10)+(x<<1));
  *vga_addr=colour;
  //screen[x][y]=colour;
}

void write_char(int x, int y, char c){
  volatile char * character_buffer = (char *) (0x09000000 + (y<<7) + x);
  *character_buffer = c;
}
void clear_screen(){
  for(int x=0;x<320;x++){
    for(int y=0;y<240;y++){
      draw_pixel(x,y,WHITE);//white background
    }
  }
}

void draw_square(int x, int y,int size, short colour){
  for(int i=x-size/2;i<=x+size/2;i++){
    for(int j=y-size/2;j<=y+size/2;j++){ 
      draw_pixel(i,j,colour);
    }
  }
}
void draw_car_square(int x, int y,int size, short colour){
  for(int i=x-size/2+2;i<=x+size/2-2;i++){
    for(int j=y-size/2;j<=y+size/2;j++){ 
      draw_pixel(i,j,colour);
    }
  }
}

void draw_obstacle(){
	if(direction==UP)
		draw_square(currentX,currentY-11,4,BLUE);
	if(direction==DOWN)
		draw_square(currentX,currentY+11,4,BLUE);
	if(direction==LEFT)
		draw_square(currentX-11,currentY,4,BLUE);
	if(direction==RIGHT)
		draw_square(currentX+11,currentY,4,BLUE);
}

void draw_car(int draw){
	int size=10;
	if (draw){
		prevX=currentX;
		prevY=currentY; 
  		if(direction==UP){
			if(currentY>=22)
				currentY--;
  		}	
   		else if(direction==DOWN){
			if(currentY<=218)
				currentY++;
  		}	
  		 if(direction==LEFT){
			 if(currentX>=22)
				currentX--;
  		}	
		   else if(direction==RIGHT){
			   if(currentX<=298)
				currentX++;
  		}	
		draw_square(prevX,prevY,size,WHITE);//need to do draw car square and ajust based on direction. we cover up the blocks
		draw_square(currentX,currentY,size,RED);
		
		if(direction==UP){
			  for(int i=currentX-(size/2)+2;i<=currentX+(size/2)-2;i++){
				  draw_pixel(i,currentY-(size/2)+1,BLACK);
				  draw_pixel(i,currentY-(size/2)+2,BLACK);
			  }
			  draw_square(prevX+(size/2)+2,prevY+(size/2)-1,2,WHITE);//bottom right
			  draw_square(prevX-(size/2)-2,prevY+(size/2)-1,2,WHITE);//bottom left
			  draw_square(prevX-(size/2)-2,prevY-(size/2)+1,2,WHITE);//top left
			  draw_square(prevX+(size/2)+2,prevY-(size/2)+1,2,WHITE);//top right
			  
			  draw_square(currentX+(size/2)+2,currentY+(size/2)-1,2,BLACK);//bottom right
			  draw_square(currentX-(size/2)-2,currentY+(size/2)-1,2,BLACK);//bottom left
			  draw_square(currentX-(size/2)-2,currentY-(size/2)+1,2,BLACK);//top left
			  draw_square(currentX+(size/2)+2,currentY-(size/2)+1,2,BLACK);//top right
		}
		if(direction==DOWN){
			  for(int i=currentX-(size/2)+2;i<=currentX+(size/2)-2;i++){
				  draw_pixel(i,currentY+(size/2)-1,BLACK);
				  draw_pixel(i,currentY+(size/2)-2,BLACK);
			  }
			  draw_square(prevX+(size/2)+2,prevY+(size/2)-1,2,WHITE);//bottom right
			  draw_square(prevX-(size/2)-2,prevY+(size/2)-1,2,WHITE);//bottom left
			  draw_square(prevX-(size/2)-2,prevY-(size/2)+1,2,WHITE);//top left
			  draw_square(prevX+(size/2)+2,prevY-(size/2)+1,2,WHITE);//top right
			  
			  draw_square(currentX+(size/2)+2,currentY+(size/2)-1,2,BLACK);//bottom right
			  draw_square(currentX-(size/2)-2,currentY+(size/2)-1,2,BLACK);//bottom left
			  draw_square(currentX-(size/2)-2,currentY-(size/2)+1,2,BLACK);//top left
			  draw_square(currentX+(size/2)+2,currentY-(size/2)+1,2,BLACK);//top right
		}
		if(direction==LEFT){
			  for(int i=currentY-(size/2)+2;i<=currentY+(size/2)-2;i++){
				  draw_pixel(currentX-(size/2)+1,i,BLACK);
				  draw_pixel(currentX-(size/2)+2,i,BLACK);
			  }
			  draw_square(prevX+(size/2)-1,prevY+(size/2)+2,2,WHITE);//bottom right
			  draw_square(prevX-(size/2)+1,prevY+(size/2)+2,2,WHITE);//bottom left
			  draw_square(prevX-(size/2)+1,prevY-(size/2)-2,2,WHITE);//top left
			  draw_square(prevX+(size/2)-1,prevY-(size/2)-2,2,WHITE);//top right
			  
			  draw_square(currentX+(size/2)-1,currentY+(size/2)+2,2,BLACK);//bottom right
			  draw_square(currentX-(size/2)+1,currentY+(size/2)+2,2,BLACK);//bottom left
			  draw_square(currentX-(size/2)+1,currentY-(size/2)-2,2,BLACK);//top left
			  draw_square(currentX+(size/2)-1,currentY-(size/2)-2,2,BLACK);//top right
		}
		if(direction==RIGHT){
			  for(int i=currentY-(size/2)+2;i<=currentY+(size/2)-2;i++){
				  draw_pixel(currentX+(size/2)-1,i,BLACK);
				  draw_pixel(currentX+(size/2)-2,i,BLACK);
			  }
			  draw_square(prevX+(size/2)-1,prevY+(size/2)+2,2,WHITE);//bottom right
			  draw_square(prevX-(size/2)+1,prevY+(size/2)+2,2,WHITE);//bottom left
			  draw_square(prevX-(size/2)+1,prevY-(size/2)-2,2,WHITE);//top left
			  draw_square(prevX+(size/2)-1,prevY-(size/2)-2,2,WHITE);//top right
			  
			  draw_square(currentX+(size/2)-1,currentY+(size/2)+2,2,BLACK);//bottom right
			  draw_square(currentX-(size/2)+1,currentY+(size/2)+2,2,BLACK);//bottom left
			  draw_square(currentX-(size/2)+1,currentY-(size/2)-2,2,BLACK);//top left
			  draw_square(currentX+(size/2)-1,currentY-(size/2)-2,2,BLACK);//top right
		}
	}
}

void change_direction(){//do we want a turning animation?
	int size=10;
	if(direction==UP){
		draw_square(currentX+(size/2)+2,currentY+(size/2)-1,2,WHITE);//bottom right
		draw_square(currentX-(size/2)-2,currentY+(size/2)-1,2,WHITE);//bottom left
		draw_square(currentX-(size/2)-2,currentY-(size/2)+1,2,WHITE);//top left
		draw_square(currentX+(size/2)+2,currentY-(size/2)+1,2,WHITE);//top right
	}
	else if(direction==DOWN){
		draw_square(currentX+(size/2)+2,currentY+(size/2)-1,2,WHITE);//bottom right
		draw_square(currentX-(size/2)-2,currentY+(size/2)-1,2,WHITE);//bottom left
		draw_square(currentX-(size/2)-2,currentY-(size/2)+1,2,WHITE);//top left
		draw_square(currentX+(size/2)+2,currentY-(size/2)+1,2,WHITE);//top right
	}
	else if(direction==LEFT){
		draw_square(currentX+(size/2)-1,currentY+(size/2)+2,2,WHITE);//bottom right
		draw_square(currentX-(size/2)+1,currentY+(size/2)+2,2,WHITE);//bottom left
		draw_square(currentX-(size/2)+1,currentY-(size/2)-2,2,WHITE);//top left
		draw_square(currentX+(size/2)-1,currentY-(size/2)-2,2,WHITE);//top right
	}
	else if(direction==RIGHT){
		draw_square(currentX+(size/2)-1,currentY+(size/2)+2,2,WHITE);//bottom right
		draw_square(currentX-(size/2)+1,currentY+(size/2)+2,2,WHITE);//bottom left
		draw_square(currentX-(size/2)+1,currentY-(size/2)-2,2,WHITE);//top left
	    draw_square(currentX+(size/2)-1,currentY-(size/2)-2,2,WHITE);//top right
	}
	direction++;
	direction%=4;
}

void set_current_pos(int x,int y){
	currentX=x;
	currentY=y;
}

void set_prev_pos(int x,int y){
	prevX=x;
	prevY=y;
}

void set_direction(char direct){
	direction=direct;
}
void draw_border(){
  for(int i=0;i<320;i++){
    for (int j=0;j<240;j++){
      if(i==10||i==310){
        draw_pixel(i,j,BLACK);//black border vertical
      }
      if(j==10||j==230){
        draw_pixel(i,j,BLACK);//black border horizontal
      }
    }
  }
}

int draw_screen(){
  clear_screen();
  draw_border();
  prevX=currentX;
  prevY=currentY;
  draw_car(1);
}

//in assembly...
/*.equ ADDR_VGA, 0x08000000
.equ ADDR_CHAR, 0x09000000

  movia r2,ADDR_VGA
  movia r3, ADDR_CHAR
  movui r4,0xffff   %White pixel
  movi  r5, 0x41    %ASCII for 'A'
  sthio r4,1032(r2)  %pixel (4,1) is x*2 + y*1024 so (8 + 1024 = 1032)
  stbio r5,132(r3)  %character (4,1) is x + y*128 so (4 + 128 = 132) */
