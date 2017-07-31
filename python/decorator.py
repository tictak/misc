#!/usr/bin/env python

def decorator1(func):
        def dec(*args):
                print 'pre action'
                result = func(*args)
                print 'post action'
                return result
        return dec

def dec_arg(arg):
        def dec(func):
                test_f1("FFFFF")
                print "DDD"
                def wrap(*args):
                        print "arg %s" %(arg)
                        result = func(*args)
                        print "arg %s" %(arg)
                        return result
                print "EEE"
                test_f1("FFFFF")
                return wrap
        return dec

def dec_arg1(arg):
        def dec(func):
                print arg
                def final(*args):
                        func(*args)
                return final
        return dec


@decorator1
def test_f1(name):
        print name
        return None

@dec_arg1("JJJ")
@dec_arg("HHH")
def test_f2(name):
        print name

test_f2('f2') #out: preaction/name2/post action
