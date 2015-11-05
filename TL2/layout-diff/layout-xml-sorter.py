#!/usr/bin/env python3

from argh import arg, dispatch_command
import argcomplete
from lxml import etree, html


def sortObjTree(tree, tag):
    """
    Given the tree for the '[OBJECTS]' group or a '[CHILDREN]' subgroup,
    sort the BASEOBJECTS within that tree by the ID of their PROPERTIES obj.
    """
    for b in tree:
        if b.find("CHILDREN") is not None:
            # sort any sub-trees of BASEOBJECTs
            sortObjTree(b.find("CHILDREN"), tag)

    # modify the object tree in place
    #~ tree[:] = sorted(tree, key=lambda el: el.find("PROPERTIES").findtext(tag))

    # Translation: for each element 'el' in 'tree' (i.e. each BASEOBJECT), find el's
    # PROPERTIES descriptor object and sort any TIMELINEDATA sub-tree contained within it.
    # The sortTimelineData() method returns the modified PROPERTIES object; from that,
    # we extract the text of the given tag (i.e. the value of its "ID" field) and use
    # that as a comparison key for 'el'. The entire list of elements in 'tree' is sorted
    # based on the key extracted from BASEOBJECT.PROPERTIES.ID field. This sorted list then
    # replaces all the the elements of 'tree', effectively sorting it in place. 
    tree[:] = sorted(tree, key=lambda el: sortTimelineData(el.find("PROPERTIES")).findtext(tag))

    # NOTE: a PROPERTIES tag could also contain a LOGICGROUP sub-tree which is a container
    # for any number of LOGICOBJECTS; however, as far as I can tell, these logicobjects are
    # seem to be consistenlty sorted by GUTS based on their ID, thus eliminating the
    # need for any further processing on our end.

    # tag = './/INTEGER64[@label="ID"]'

def sortTimelineData(prop, tag='INTEGER64[@label="OBJECTID"]'):
    """
    Given a BASEOBJECT.PROPERTIES object, find if it contains a TIMELINEDATA sub-tree and
    sort the elements of that sub-tree on the TIMELINEDATA.TIMELINEOBJECT::OBJECTID field.

    prop = a PROPERTIES object (first child of a BASEOBJECT)
    tag = field of TIMELINEOBJECT to sort by (default 'INTEGER64[@label=OBJECTID]'
     """

    #Find the timelinedata container; there's only ever one of these elements
    # in a Properties tag, and it only ever contains one direct field: its ID.
    # We could "iterate" over the list of 0 or 1 to avoid the "not None" check, but I
    # think "find()" is much faster/more efficient than findall())
    tldata = prop.find("TIMELINEDATA")
    if tldata is not None:
        # as mentioned before, the only direct field is the id, and it's the first
        # item in the list before the timelineobjects, so we SHOULD be able
        # to safely use tldata[1:] to sort the objects only. If that turns out not
        # to be true, we could try tldata.index(tldata.find("TIMELINEOBJECT"))...
        # but that's gross and i'd like to avoid it :P

        # Note to self: remember how "TIMELINEOBJECT" only finds direct children, as
        # opposed to ".//TIMELINEOBJECT", which would search all subtrees.  End result
        # would probably be the same, but to be safe...and maybe this is probably faster??
        # Thus, this command replaces everything but the first item in tldata (i.e. the ID)
        # with the list of its TLObject children sorted by their "OBJECTID".
        tldata[1:] = sorted(tldata.findall("TIMELINEOBJECT"), key=lambda tlo: tlo.findtext('INTEGER64[@label="OBJECTID"]'))


    # now return the modified "PROPERTIES" object to the calling function for further action
    return prop
    
    
        

    

 

#~ filename, tag = sys.argv[1:]

@arg('xml', help='Pre-converted TL2 .layout->xml file to load')
@arg('--tag', help='Name or XPATH of the PROPERTIES sub tag to sort on')
def main(xml, tag='INTEGER64[@label="ID"]'):

    doc = etree.parse(xml, etree.XMLParser(remove_blank_text=True))
    # doc = etree.parse(xml)
    obs = doc.getroot().find("OBJECTS")

    sortObjTree(obs, tag)

    # obs[:] = sorted(obs, key=lambda el: el.find("PROPERTIES").findtext(tag))

    # passing the 'str' function for encoding= makes tostring()
    # return enencoded unicode rather than a bytes object
    # (same as .decode() on the result)
    print (etree.tostring(doc, pretty_print=True, encoding='unicode'))
    # etree.dump(doc, pretty_print=True)



if __name__ == '__main__':
    dispatch_command(main)
