#!/usr/bin/python
import codecs
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
        self.tempAuthor = ""
        self.hasSp = False

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
        if tag == "author":
            self.author = ""

    def endElement(self, tag):
        if self.CurrentData == "title":
            print "Title: ",self.title 
        elif self.CurrentData == "year":
            print "Year: ",self.year
        elif self.CurrentData =="booktitle":
            print "booktitle: ",self.booktitle
        elif self.CurrentData =="journal":
            print "Journal: ",self.journal
        if tag =="author":
            print "Author: ",self.author 
            try:
                cur.execute("INSERT INTO authorship(pubkey, author) VALUES(%s, %s)", (self.pubkey , self.author))
            except psycopg2.DatabaseError as e:
                print e
                return e.pgerror

        #insert into tables
        if tag == "article":
            try:
                cur.execute("INSERT INTO article(pubkey, title,journal, year) VALUES(%s,%s,%s,%s)", (self.pubkey,self.title, self.journal, self.year))
            except psycopg2.DatabaseError as e:
                print e
                return e.pgerror
        if tag == "inproceedings":
            try:
                cur.execute("INSERT INTO inproceedings(pubkey, title,booktitle, year) VALUES(%s,%s,%s,%s)", (self.pubkey,self.title, self.booktitle, self.year))
            except psycopg2.DatabaseError as e:
                print e
                return e.pgerror

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
            self.author = self.author+content
            #self.tempAuthor += content
            #content = ""
    

if (__name__ == "__main__"):
    #Try to connect
    try:
        conn = psycopg2.connect(dbname = 'dblp', user = 'dblpuser', password = 'password')
        conn.autocommit = True
    except:
        print "Unable to connect the database"
        exit()
    print "Successfully connected to the databese"
    
    #cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    cur = conn.cursor()
    try: 
        cur.execute("DROP TABLE IF EXISTS authorship")
        cur.execute("CREATE TABLE IF NOT EXISTS authorship(pubkey text,author text, PRIMARY KEY(pubkey, author))")
    except:
        print "Unable to create Table -- Authorship"
    
    try:
        cur.execute("DROP TABLE IF EXISTS inproceedings")
        cur.execute("CREATE TABLE IF NOT EXISTS inproceedings(pubkey varchar(255) PRIMARY KEY,title text,booktitle varchar(255),year int)")
    except:
        print "Unable to create table -- inproceedings"

    try:
        cur.execute("DROP TABLE IF EXISTS article")
        cur.execute("CREATE TABLE IF NOT EXISTS article(pubkey varchar(255) PRIMARY KEY,title text,journal varchar(255),year int)")
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
