from flask import Flask,render_template,Blueprint,request

app = Blueprint('app', __name__)

@app.route("/",methods=['GET','POST'])
def akinator():
    if request.method == 'GET' :
        return render_template("akinator.html",question=None)
    elif request.method == 'POST':
        answer = request.form['answer']
        if answer == "yes":
            question = "yes"
        elif answer == "probably":
            question = "probably"
        elif answer == "probably_no":
            question = "probably_no"
        elif answer == "no":
            question = "no"
        elif answer == "dont_know":
            question = "dont_know"
        else:
            question = None
        return render_template("akinator.html",question=question)