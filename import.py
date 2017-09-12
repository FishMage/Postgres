#!/usr/bin/python
import xml.sax

class DblpHandler(xml.sax.ContentHandler):
    def __init__(self):
        self.CurrentData = ""
        self.pubkey = ""
        self.title = ""
        self.journal = ""
        self.year = ""
        self.booktitle = ""
        self.author = ""

    def startElement (self, tag, attributes):
        self.CurrentData = tag
        if tag == "article":
            print "***Article***"
            pubkey = attributes["key"]
            print "Pubkey:",pubkey

        if tag == "inproceedings":
            print "***inproceedings***"
            pubkey = attributes["key"]
            print "Pubkey:",pubkey

        if tag == "authorship":
            print "***authorship***"
            pubkey = attributes["key"]
            print "Pubkey:",pubkey

    def endElement(self, tag):
        if self.CurrentData == "title":
            print "Title: ",self.title 
        elif self.CurrentData == "year":
            print "Year: ",self.year
        elif self.CurrentData =="booktitle":
            print "booktitle: ",self.booktitle
        elif self.CurrentData =="journal":
            print "Journal: ",self.journal
        elif self.CurrentData =="author":
            print "Author: ",self.author 
        self.CurrentData = ""

    def characters(self, content):
        if self.CurrentData == "title":
            self.title= content
        elif self.CurrentData == "year":
            self.year = content
        elif self.CurrentData =="booktitle":
            self.booktitle = content
        elif self.CurrentData =="journal":
            self.journal = content
        elif self.CurrentData =="author":
            self.author = content
if (__name__ == "__main__"):
    # create an XMLReader
    parser = xml.sax.make_parser()
    # turn off nam epsaces
    parser.setFeature(xml.sax.handler.feature_namespaces, 0)
    
    #ovverride the default Context Handler
    Handler = DblpHandler()    
    parser.setContentHandler(Handler)
    parser.parse("dblp-2017-08-24.xml")
