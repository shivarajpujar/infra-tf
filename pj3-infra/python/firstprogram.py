num1 = eval(input("enter num1:"))
num2 = eval(input("enter num2:"))
num3 = eval(input("enter num3:"))

if(num1>=num2 and num1>=num3):
    print("num1 is greatest:",num1)
elif(num2>=num3):
    print("num2 is greatest:",num2)
else:
    print("num3 is greatest:",num3)

