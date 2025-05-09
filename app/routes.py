from flask import Flask, render_template, Blueprint, request, session, redirect, url_for
from app.database.generate_database import AnswerValue
from app.akinator import Akinator
import numpy as np

app = Blueprint('app', __name__)

answer_value = {"yes":AnswerValue.YES.value,"probably":AnswerValue.PROBABLY.value,"no":AnswerValue.NO.value,"probably_no":AnswerValue.PROBABLY_NO.value,"unknown":AnswerValue.UNKNOWN.value}
value_answer = {AnswerValue.YES.value:"はい",AnswerValue.PROBABLY.value:"たぶんそう",AnswerValue.NO.value:"いいえ",AnswerValue.PROBABLY_NO.value:"たぶん違う",AnswerValue.UNKNOWN.value:"分からない"}

@app.route("/",methods=['GET','POST'])
def question_page():
    if request.method == 'GET':
        #セッションの初期化
        session.clear()

        #アキネーターのインスタンスを生成
        akinator = Akinator()

        #質問を取得
        question = akinator.get_question()
        questions = []
        questions.append(question)
        
        session["question"] = questions

        return render_template("akinator.html",question=question,QA = None,cards = None)
    
    elif request.method == 'POST':
        #回答の取得
        answer = request.form.get("answer")
        
        #今までの回答を取得
        answers = session.get("answer", [])
        
        #今までの質問を取得
        questions = session.get("question", [])
        
        if answer in answer_value:
            #回答の取得
            answer = answer_value[answer]
                    
        elif answer == "reset":
            #リセット
            session.clear()
            return redirect(url_for("app.question_page"))
        
        elif answer == "revert":
            if not answers:
                #リセット
                session.clear()
                return redirect(url_for("app.question_page"))
            answers.pop()
            session["answer"] = answers
            
            if len(questions) < 2:
                #リセット
                session.clear()
                return redirect(url_for("app.question_page"))
            questions.pop()
            question = questions[-1]
            
            QA = []
            for i in range(len(answers)):
                QA.append((questions[i],value_answer[answers[i]]))
                
            #アキネーターのインスタンスを生成
            akinator = Akinator(questions,answers)
            #上位のカードを取得(順位,カード名,確率)
            is_answer,cards = akinator.get_card()
            if is_answer:
                return redirect(url_for("app.answer_check_page",card=cards[0][1]))
            
            return render_template("akinator.html",question=question,QA = QA,cards = cards)

        else:
            #リセット
            session.clear()
            return redirect(url_for("app.question_page"))

        #回答の追加
        answers.append(answer)
        
        #アキネーターのインスタンスを生成
        akinator = Akinator(questions,answers)
        
        #上位のカードを取得(順位,カード名,確率)
        is_answer,cards = akinator.get_card()
        if is_answer:
            return redirect(url_for("app.answer_check_page",card=cards[0][1]))
        
        #質問の取得
        question = akinator.get_question()
        
        questions.append(question)
        
        session["question"] = questions
        session["answer"] = answers
        
        QA = []
        for i in range(len(answers)):
            QA.append((questions[i],value_answer[answers[i]]))
        
        return render_template("akinator.html",question=question,QA = QA,cards = cards)

@app.route("/answer_check",methods=['GET','POST'])
def answer_check_page():
    if request.method == 'GET':
        card = request.args.get('card')
        if card is None:
            return redirect(url_for("app.question_page"))
        else:
            return render_template("answer_check.html",card=card)
    elif request.method == 'POST':
        answer = request.form.get("answer")
        if answer == "yes":
            #正解
            return redirect(url_for("app.answer_page",answer=answer))
        elif answer == "no":
            #不正解
            return redirect(url_for("app.answer_page",answer=answer))

@app.route("/answer",methods=['GET','POST'])
def answer_page():
    if request.method == 'GET':
        answer = request.args.get('answer')
        if answer  == "yes":
            return render_template("answer.html",answer=answer)
        elif answer == "no":
            return render_template("answer.html",answer=answer)
    elif request.method == 'POST':
        play_again = request.form.get("play_again")
        if play_again == "yes":
            #リセット
            session.clear()
            return redirect(url_for("app.question_page"))