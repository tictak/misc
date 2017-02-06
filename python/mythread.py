# !/usr/bin/env python  
# -*- coding:utf-8 -*-  

import Queue  
import threading  
import time  

def get_data(data):
        print data


class MyThread(threading.Thread):
        def __init__(self,queue):
                threading.Thread.__init__(self)
                self.queue = queue
                self.setDaemon(True)
                self.start()
        def run(self):
                while True:
                        do,args = self.queue.get()
                        print "get one job"
                        do(args)


class  MyThreadPool():
        def __init__(self,thread_num=9):
                self.queue = Queue.Queue()
                self.threads = []
                self.__init__pool(thread_num)

        def __init__pool(self,thread_num):
            for i in range (thread_num):
                    oneThread = MyThread(self.queue)
                    self.threads.append(oneThread)

        def add_job(self,func,*args):
                self.queue.put((func,list(args)))

pool = MyThreadPool(3)
for i in range(100):
        pool.add_job(get_data,i)
time.sleep(4)
