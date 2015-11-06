#!/usr/bin/env python

import sys
import os
from os.path import expanduser
import time
import copy
import random
import traceback
import threading



import curses
from curses import KEY_DOWN, KEY_UP, KEY_RIGHT, KEY_LEFT

# Accelerating python :)
try:
    import psyco
    psyco.full()
except ImportError:
    pass

#Setting the windows size
def get_terminal_size(fd=1):
    try:
        import fcntl, termios, struct
        hw = struct.unpack('hh', fcntl.ioctl(fd, termios.TIOCGWINSZ, '1234'))
    except:
        try:
            hw = (os.environ['LINES'], os.environ['COLUMNS'])
        except:
            hw = (25, 80)
    return hw

g_initialTerminalSize = get_terminal_size()

def setTerminalSize(rows, cols):
    try:
        sys.stdout.write("\x1b[8;{rows};{cols}t".format(rows=rows, cols=cols))
    except Exception:
        print "Couldn't resize the window"
    os.environ['LINES'] = str(cols)
    os.environ['COLUMNS'] = str(rows)

setTerminalSize(30, g_initialTerminalSize[1])



DEBUG = False

# Map objects
MAP_WALL = -1
MAP_EMPTY = 0
MAP_DOT = -253
MAP_GHOST = -254
MAP_PLAYER = -255

# Key mapping
MOVE_UP = (0,-1)
MOVE_DOWN = (0,1)
MOVE_LEFT = (-1,0)
MOVE_RIGHT = (1,0)

# Tweak the speed!
PLAYER_TIMEOUT = 0.05
GHOST_TIMEOUT = 0.5

# Globals
g_isPlayerAlive = True
map = []

# Global locks for map and alive status variables
map_lock = threading.Lock()
alive_status_lock = threading.Lock()

# Log facility
#try:
#    home = expanduser("~")
#    sys.stderr = sys.stdout = open(home + "/tmp/pacman.log","a")
#except:
#    print "Couldn't create log file"

def log(msg):
    if DEBUG:
        sys.stdout.write(msg)
        sys.stdout.flush()


# Ghost class. 
class Ghost(threading.Thread):
    def __init__(self, game_data):
        threading.Thread.__init__(self)
        #self._game_data = game_data
        self._screen = game_data['screen']
        self._pos = game_data['pos']
        self.size = len(map)

    def find_player(self):
        for y in xrange(self.size):
            for x in xrange(self.size):
                if map[x][y] == MAP_PLAYER:
                    return (x,y)
        log("He's gone! This can't be true!")
        return ()
 
    def find_path(self, _map, pos, player_pos):
        pos_x, pos_y = pos
        # Creating local copy of map
        map = copy.deepcopy(_map)
        max_moves = 0
        for y in xrange(self.size):
            for x in xrange(self.size):
                if map[x][y] == MAP_PLAYER:
                    # Mark cell of target
                    map[x][y] = 1
                elif map[x][y] == MAP_WALL:
                    continue
                elif map[x][y] == MAP_GHOST and not (pos_x==x and pos_y==y):
                    continue
                else:
                    # Mark empty fields as 0. Calculating maximum number of moves
                    map[x][y] = 0
                    max_moves += 1

        log("%s: max moves: %d\n" % (self.getName(),max_moves))

        value = 0

        # Main path finding loop
        for i in xrange(max_moves):
            # For each move increase value of cell
            value += 1
            for y in xrange(1,self.size-1):
                for x in xrange(1,self.size-1):
                    # Calculate distance of next move
                    if map[x][y] == value:
                        if map[x+1][y] == 0: map[x+1][y] = value + 1
                        if map[x-1][y] == 0: map[x-1][y] = value + 1
                        if map[x][y+1] == 0: map[x][y+1] = value + 1
                        if map[x][y-1] == 0: map[x][y-1] = value + 1
        
        #log("%s: DUMP:\n" % self.getName())
        #for y in range( self.size ):
        #    for x in range( self.size ):
        #        log("%d\t" % map[x][y])
        #    log("\n")      

        value = map[pos_x][pos_y]

        log("%s: Number of moves left: %d\n" % (self.getName(), value))

        x = pos_x
        y = pos_y

        if value >=2:
            value -= 1
        
        # Choose next step
        if map[x+1][y] == value:
            return MOVE_RIGHT
        elif map[x-1][y] == value:
            return MOVE_LEFT
        elif map[x][y+1] == value:
            return MOVE_DOWN
        elif map[x][y-1] == value:
            return MOVE_UP
        
        log("Don't panic, activating random method!\n")
        
        # Old random method :)
        if random.choice( (0,1) ):
            return (random.choice( (-1,1)) ,0)
        else:
            return (0, random.choice( (-1,1)) )

    # Ghost main loop. It uses global map and alive status.
    # Runs until player wins or dies from other ghost
    def loop(self):
        global g_isPlayerAlive, alive_status_lock
        global map, map_lock
        map_under_me = MAP_EMPTY
        while g_isPlayerAlive:
            player_pos = self.find_player()
            if not player_pos:
                log("Cannot find player")
                time.sleep(GHOST_TIMEOUT)
                continue
            #log("PLAYER is at: %d:%d\n" % (player_pos[0], player_pos[1]) )
            
            old_x, old_y = self._pos
            direction = self.find_path(map, self._pos, player_pos)
            #log("\nnew ghost DIRECTION" + str(direction) + "\n")

            new_x = old_x + direction[0]
            new_y = old_y + direction[1]

            if map[new_x][new_y] == MAP_WALL or map[new_x][new_y] == MAP_GHOST:
                #log("Ooops, wall..." + self.getName())
                new_x = old_x
                new_y = old_y
            elif map[new_x][new_y] == MAP_PLAYER:
                alive_status_lock.acquire()
                g_isPlayerAlive = False
                alive_status_lock.release()

                self._screen.addch(old_y, old_x, c)
                self._screen.addch(new_y, new_x, "$", curses.color_pair(1))
                log("Ghost: '%s': I killed him!!!\n" % self.getName())
                return
            else:
                map[old_x][old_y] = map_under_me
                map_under_me = map[new_x][new_y]
                map_lock.acquire()
                map[new_x][new_y] = MAP_GHOST
                map_lock.release()
                self._pos = (new_x, new_y)

                if map[old_x][old_y] == MAP_EMPTY:
                    c = " "
                elif map[old_x][old_y] == MAP_DOT:
                    c = "."
                elif map_under_me == MAP_GHOST:
                    c = "$"
                else:
                    raise Exception, "This can't be true. Map is: %s, c:%s\n" % (map_under_me, c)

                self._screen.addch(old_y, old_x, c)
                self._screen.addch(new_y, new_x, "$", curses.color_pair(1))
                
            time.sleep(GHOST_TIMEOUT)
        log("Player is dead, exiting...")

    def run(self):
        #log("Ghost '%s': Let's begin!\n" % self.getName())
        self.loop()
        pass


# Main logic. Interaction with player.
# Map, ncurses and ghosts initialization
class Game:
    def __init__(self):
        self.player_pos = (1,1)
        
        self._dots = 0
        self._map = []
        self._ghosts = []
        self._init_map(expanduser("~") + "/tmp/map.dat")
        #self._init_map("map.dat")
        self._init_curses()
        self._init_ghosts()
    


    def _init_map(self, path):
        global map, map_lock
        map_array = open(path, "r").readlines()
        self.size = len(map_array)
        map = [ [ [] for i in xrange(self.size) ] for j in xrange(self.size) ]
        for y in range(self.size):
            for x in range(self.size):
                if map_array[y][x] == " ":
                    value = MAP_DOT
                    self._dots += 1
                elif map_array[y][x] == "@":
                    value = MAP_PLAYER
                elif map_array[y][x] == "$":
                    value = MAP_GHOST
                    self._ghosts.append([(x,y)])
                else:
                    value = MAP_WALL
                
                map[x][y] = value
        self._map = map_array

    def _init_curses(self):
        self._screen = curses.initscr()
        curses.noecho()
        curses.cbreak()
        curses.start_color()
        curses.use_default_colors()
        curses.init_pair(1, curses.COLOR_RED, -1)
        curses.init_pair(2, curses.COLOR_BLACK, 3)
        self._screen.keypad(1)
        self._screen.nodelay(1)
        self._screen.refresh()

    # Creating ghost threads with game data parameters - 
    #   screen handler and self positions
    def _init_ghosts(self):
        for ghost in self._ghosts:
            game_data = {
                'screen': self._screen,
                'pos': ghost[0]
            }
            ghost.append( Ghost(game_data) ) 

    def _draw_map(self):
        for y in range( self.size ):
            for x in range( self.size ):
                value = map[x][y]
                if value == MAP_WALL:
                    c = self._map[y][x]
                elif value == MAP_DOT:
                    c = "."
                elif value == MAP_PLAYER:
                    c = self._map[y][x]
                elif value == MAP_GHOST:
                    c = self._map[y][x]
                else:
                    raise Exception, "This can't be true!"
                
                if c == "$":
                    self._screen.addch(y,x,c, curses.color_pair(1))
                elif c == "@":
                    self._screen.addch(y,x,c, curses.color_pair(2))
                else:
                    self._screen.addch(y,x,c)

        self._screen.refresh()

    def dump_map(self):
        for y in range( self.size ):
            for x in range( self.size ):
                log("%d\t" % map[x][y])
            log("\n")

    # Main loop. Reads player key strokes and decrement dots
    def _loop(self):
        global g_isPlayerAlive, alive_status_lock
        while g_isPlayerAlive:
            log("Global tick. Dots left: %d\n" % self._dots )
            c = self._screen.getch()
            
            if c == KEY_UP:
                direction = (0,-1)
            elif c == KEY_DOWN:
                direction = (0,1)
            elif c == KEY_LEFT:
                direction = (-1,0)
            elif c == KEY_RIGHT:
                direction = (1,0)
            elif c == ord("q"):
                self._screen.addstr(self.size + 1, 0, "Press 'Enter' to exit")
                self._screen.refresh()
                raise KeyboardInterrupt, "'q' was pressed, exiting..."
            else:
                direction = None

            if c >= 0 and direction:
                self.move_player(direction)
        
            if not self._dots:
                self._screen.addstr(int(self.size/2), 0, "You won!!")
                self._screen.refresh()
                self.stop("You won!")
                return

            # Prevent moving objects from blinking
            self._screen.move(0,0)

            self._screen.refresh()
            time.sleep(PLAYER_TIMEOUT)

        log("\nGame over\n")
        self._screen.addstr(int (self.size/2), 0, "  Game over. You died!   ", curses.color_pair(1))
        self._screen.addstr(self.size + 1, 0, "Press 'Enter' to exit.")
        self._screen.refresh()
        self.stop("Game over. You died!")
        return

    def move_player(self, direction):
        global map, map_lock
        #log(str(direction))
        old_x, old_y = self.player_pos
        new_x = old_x + direction[0]
        new_y = old_y + direction[1]

        if map[new_x][new_y] == MAP_WALL:
            #log("Ooops, wall...")
            return
        elif map[new_x][new_y] == MAP_GHOST:
            curses.beep()
            
            alive_status_lock.acquire()
            g_isPlayerAlive = False
            alive_status_lock.release()

            return
        elif map[new_x][new_y] == MAP_DOT:
            #log("Ate a dot")
            self._dots -= 1
        elif map[new_x][new_y] == MAP_EMPTY:
            pass
        else:
            #log("Pos: " + str(self._map[new_x][new_y]) + "\n")
            raise Exception, "This can't be true!"

        map_lock.acquire()
        map[old_x][old_y] = MAP_EMPTY
        map[new_x][new_y] = MAP_PLAYER
        map_lock.release()
        self.player_pos = (new_x, new_y)

        self._screen.addch(old_y, old_x, " ")
        self._screen.addch(new_y, new_x, "@", curses.color_pair(2))
        
        self._screen.addstr(self.size, 0, "Dots left: %d  " % self._dots, curses.A_REVERSE)
        self._screen.addstr(self.size + 1, 0, "Press 'q' to exit.")
        

    # Draw map. Start ghosts threads
    def start(self):
        self._draw_map()
        for ghost in self._ghosts:
            ghost[1].setDaemon(1)
            ghost[1].start()
        self._loop()

    # Restoring default terminal settings
    def stop(self, text=""):
        global g_isPlayerAlive, alive_status_lock
        alive_status_lock.acquire()
        g_isPlayerAlive = False
        alive_status_lock.release()

        self._screen.clear()
        curses.nocbreak()
        self._screen.keypad(0)
        curses.echo()

        #curses.endwin()
        #sys.__stdout__.write("%s!\n" % text)


if __name__ == "__main__":
    try:
        g = Game()
        g.dump_map()
        g.start()
    
    except KeyboardInterrupt:
        log("Interrupted from keyboard\n")
        g.stop()

    except Exception, e:
        print " ".join(traceback.format_exception(*sys.exc_info()))

    raw_input()
    curses.endwin()
    sys.stdout = sys.stdout
    setTerminalSize(g_initialTerminalSize[0], g_initialTerminalSize[1])
