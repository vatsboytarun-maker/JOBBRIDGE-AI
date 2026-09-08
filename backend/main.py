import io, sqlite3
from typing import List
import requests
from fastapi import FastAPI, UploadFile, File, HTTPException
from pydantic import BaseModel
from pypdf import PdfReader

app=FastAPI(title="JOBBRIDGE AI",version="1.0")
KEYWORDS=["procurement","purchasing","commercial management","vendor management","vendor negotiation","rfq","quotation","contract management","amc","sap","erp","excel","facility management","facilities manager","administration","admin manager","sla","maintenance","housekeeping","security","electrical maintenance","interior","fit-out","budgeting","cost optimization","purchase order","supply chain","site operations"]
class Ticket(BaseModel):
 name:str
 location:str="Delhi NCR"
 keywords:List[str]
 min_score:int=70
 active:bool=True
@app.get("/")
def root(): return {"app":"JOBBRIDGE AI","status":"running","docs":"/docs"}
@app.post("/resume/extract")
async def resume_extract(file:UploadFile=File(...)):
 if not file.filename.lower().endswith(".pdf"): raise HTTPException(400,"Upload a PDF resume")
 data=await file.read()
 text="\n".join(p.extract_text() or "" for p in PdfReader(io.BytesIO(data)).pages)
 found=sorted(set(k for k in KEYWORDS if k in text.lower()))
 return {"filename":file.filename,"keywords":found,"text_preview":text[:1000]}
@app.post("/ticket/query")
def ticket_query(ticket:Ticket):
 return {"ticket":ticket.name,"queries":[f"{k} jobs {ticket.location}" for k in ticket.keywords],"min_score":ticket.min_score}
@app.get("/greenhouse/{board_token}")
def greenhouse(board_token:str):
 r=requests.get(f"https://boards-api.greenhouse.io/v1/boards/{board_token}/jobs",timeout=20)
 if r.status_code!=200: raise HTTPException(r.status_code,"Unable to load public Greenhouse board")
 return {"source":"greenhouse","jobs":[{"title":x.get("title"),"location":(x.get("location") or {}).get("name"),"url":x.get("absolute_url")} for x in r.json().get("jobs",[])]}
@app.get("/lever/{site}")
def lever(site:str):
 r=requests.get(f"https://api.lever.co/v0/postings/{site}?mode=json",timeout=20)
 if r.status_code!=200: raise HTTPException(r.status_code,"Unable to load public Lever postings")
 return {"source":"lever","jobs":[{"title":x.get("text"),"location":(x.get("categories") or {}).get("location"),"url":x.get("hostedUrl")} for x in r.json()]}
@app.post("/jobs/score")
def score(ticket:Ticket,job_title:str,job_description:str=""):
 hay=(job_title+" "+job_description).lower()
 hits=[k for k in ticket.keywords if k.lower() in hay]
 score=round(100*len(hits)/max(1,len(ticket.keywords)))
 return {"score":score,"matched":hits,"eligible":score>=ticket.min_score}
