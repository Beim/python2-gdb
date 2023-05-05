import time

def hello_world():
    return "<p>Hello, World!</p>"

if __name__ == "__main__":
    while True:
        print('sleep...')
        time.sleep(10)
        hello_world()
