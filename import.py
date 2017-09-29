#RESULTS:
#AUTHORSHIP:10872613
#ARTICLE: 1685783
#INPROCEEDINGS:2032515

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

        #buffer to store authorship info of a single paper
        self.tempAuthor = []
        self.hasSp = False

        #boolean to control adding author
        self.timeToAdd = 0

    def startElement (self, tag, attributes):
        self.CurrentData = tag
        if self.CurrentData == "article":
            self.pubkey = attributes["key"]
            self.timeToAdd = True
            self.tempAuthor = [] 
            self.author = ""
        
        if self.CurrentData == "inproceedings":
            self.pubkey = attributes["key"]
            self.timeToAdd = True
            print "***inproceedings***"
            self.author = ""
            self.tempAuthor = [] 

        if self.CurrentData == "author":
            self.author = ""

    def endElement(self, tag):
       # if self.CurrentData == "title":
       #     print "Title: ",self.title 
       # elif self.CurrentData == "year":
       #     print "Year: ",self.year
       # elif self.CurrentData =="booktitle":
       #     print "booktitle: ",self.booktitle
       # elif self.CurrentData =="journal":
       #     print "Journal: ",self.journal
        if tag =="author":
            print "Author", self.author
            self.tempAuthor.append(self.author)
            self.author = ""
        #insert into tables
        if (tag == "article" or tag == "inproceedings"):
            #add author info by poping the tempAuthor buffer
            for thisAuthor in self.tempAuthor:
                try:
                    cur.execute("INSERT INTO authorship(pubkey, author) VALUES(%s, %s)", (self.pubkey , thisAuthor))
                except psycopg2.DatabaseError as e:
                    print e
                    return e.pgerror
            self.timeToAdd = False
            self.tempAuthor = []

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
        if self.timeToAdd:
            if self.CurrentData == "title":
                self.title= content
            if self.CurrentData == "year":
                self.year = int(content)
            if self.CurrentData =="booktitle":
                self.booktitle = content
            if self.CurrentData =="journal":
                self.journal = content
            # Concatonate
            if self.CurrentData =="author":
                self.author += content
            #self.tempAuthor += content
            #content = ""
    

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
        cur.execute("DROP TABLE IF EXISTS authorship cascade")
        cur.execute("CREATE TABLE IF NOT EXISTS authorship(pubkey text,author text, PRIMARY KEY(pubkey, author))")
    except:
        print "Unable to create Table -- Authorship"
    
    try:
        cur.execute("DROP TABLE IF EXISTS inproceedings cascade")
        cur.execute("CREATE TABLE IF NOT EXISTS inproceedings(pubkey varchar(255) PRIMARY KEY,title text,booktitle varchar(255),year int)")
    except:
        print "Unable to create table -- inproceedings"

    try:
        cur.execute("DROP TABLE IF EXISTS article cascade")
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
