
def isIterable(myObject):
    try:
        iterator = iter(myObject)
    except TypeError:
        return False
    else:
        return True