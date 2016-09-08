from gen.Python3Visitor import Python3Visitor


class Interpreter(Python3Visitor):
    def __init__(self):
        super(Python3Visitor, self).__init__()
        self.vars = dict()

    def visitPrint(self, ctx):
        print(self.visit(ctx.expr()))

    def visitFunction_def(self, ctx):
        func_args = [arg for arg in ctx.arguments().getText().split(',')] if ctx.arguments() else []
        self.vars[ctx.ID().getText()] = (ctx.function_body(), func_args)

    def visitAssignment(self, ctx):
        self.vars[ctx.ID().getText()] = self.visit(ctx.expr())

    def visitReturn_stat(self, ctx):
        return self.visit(ctx.expr())

    def visitNumberAtom(self, ctx):
        num = ctx.getText()
        return float(num) if '.' in num else int(num)

    def visitStringAtom(self, ctx):
        return ctx.getText().strip('\'"')

    def visitNilAtom(self, ctx):
        return None

    def visitIdAtom(self, ctx):
        return self.vars.get(ctx.ID().getText())

    def visitBooleanAtom(self, ctx):
        if ctx.TRUE():
            return True
        elif ctx.FALSE():
            return False

    def visitFuncCallAtom(self, ctx):
        func = self.vars.get(ctx.ID().getText())
        if not func:
            print('Nie znaleziono funkcji w vars (brak definicji?)')
            return

        if len(func[1]) > 0 and not ctx.call_arguments():
            print('Nie podano argumentow funkcji')
            return

        if ctx.call_arguments():
            call_args_atoms = ctx.call_arguments().atom()

            if len(call_args_atoms) != len(func[1]):
                print('Nieidentyczna liczba podanych argumentow wzgledem definicji funkcji')
                return

            for name, value in zip(func[1], [self.visit(arg) for arg in call_args_atoms]):
                self.vars[name] = value

        result = self.visit(func[0])

        for name in func[1]:
            if name in self.vars:
                del self.vars[name]

        return result

    def visitNotExpr(self, ctx):
        return not self.visit(ctx.expr())

    def visitMulExpr(self, ctx):
        lval = self.visit(ctx.expr()[0])
        rval = self.visit(ctx.expr()[1])
        if ctx.MUL():
            return lval * rval
        elif ctx.DIV():
            return lval / rval

    def visitAddExpr(self, ctx):
        lval = self.visit(ctx.expr()[0])
        rval = self.visit(ctx.expr()[1])
        if ctx.PLUS():
            return lval + rval
        elif ctx.MINUS():
            return lval - rval

    def visitMinusExpr(self, ctx):
        return -(self.visit(ctx.expr()))

    def visitFor_stat(self, ctx):
        for i in range(int(ctx.INT().getText())):
            self.vars['i'] = i
            self.visit(ctx.for_body())
        del self.vars['i']
