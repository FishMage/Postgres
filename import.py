#!/usr/bin/python
import psycopg2
import xml.sax
import psycopg2.extras

con = None
cur = None

class DblpHandler(xml.sax.ContentHandler):
    def __init__(self):
        self.CurrentData = ""
        self.pubkey = ""
        self.title = ""
        self.journal = ""
        self.year = None  
        self.booktitle = ""
        self.author = ""

    def startElement (self, tag, attributes):
        self.CurrentData = tag
        if tag == "article":
            print "***Article***"
            self.pubkey = attributes["key"]
            print "Pubkey:",self.pubkey
        
        if tag == "inproceedings":
            print "***inproceedings***"
            self.pubkey = attributes["key"]
            print "Pubkey:",self.pubkey

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
            cur.execute("INSERT INTO authorship(pubkey, author) VALUES(%s, %s)", (self.pubkey , self.author))

        #insert into tables
        if tag == "article":
            cur.execute("INSERT INTO article(pubkey, title,journal, year) VALUES(%s,%s,%s,%s)", (self.pubkey,self.title, self.journal, self.year))

        if tag == "inproceedings":
            cur.execute("INSERT INTO inproceedings(pubkey, title,booktitle, year) VALUES(%s,%s,%s,%s)", (self.pubkey,self.title, self.booktitle, self.year))
        self.CurrentData = ""

    def characters(self, content):
        if self.CurrentData == "title":
            self.title= content
        elif self.CurrentData == "year":
            self.year = int(content)
        elif self.CurrentData =="booktitle":
            self.booktitle = content
        elif self.CurrentData =="journal":
            self.journal = content
        elif self.CurrentData =="author":
            self.author = content
if (__name__ == "__main__"):
    #Try to connect
    try:
        conn = psycopg2.connect(dbname = 'dblptest', user = 'dblpuser', password = 'password')
        conn.autocommit = True
    except:
        print "Unable to connect the database"
        exit()
    print "Successfully connected to the databese"
    
    #cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    cur = conn.cursor()
    try: 
        cur.execute("DROP TABLE IF EXISTS authorship")
        cur.execute("CREATE TABLE IF NOT EXISTS authorship(pubkey varchar(255),author varchar(255))")
    except:
        print "Unable to create Table -- Authorship"
    
    try:
        cur.execute("DROP TABLE IF EXISTS inproceedings")
        cur.execute("CREATE TABLE IF NOT EXISTS inproceedings (pubkey varchar(255),title varchar(255),booktitle varchar(255),year int)")
    except:
        print "Unable to create table -- inproceedings"

    try:
        cur.execute("DROP TABLE IF EXISTS article")
        cur.execute("CREATE TABLE IF NOT EXISTS article(pubkey varchar(255),title varchar(511),journal varchar(255),year int)")
    except:
        print "Unable to create table -- article"
    #conn.commit()
    print "Done Creating Tables"
    # create an XMLReader

    parser = xml.sax.make_parser()
    # turn off nam epsaces
    parser.setFeature(xml.sax.handler.feature_namespaces, 0)
    
    #ovverride the default Context Handler
    Handler = DblpHandler()    
    parser.setContentHandler(Handler)
    parser.parse("dblp-2017-08-24.xml")
