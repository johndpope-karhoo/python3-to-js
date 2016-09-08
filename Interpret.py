from gen.Python3Visitor import Python3Visitor


class Interpreter(Python3Visitor):
    def __init__(self):
        super(Python3Visitor, self).__init__()
        self.vars = dict()

    def visitPrint(self, ctx):
        print(self.visit(ctx.expr()))

    def visitFunction_def(self, ctx):
        pass
    #     self.result_buffer += '\nfunction {name}('.format(name=ctx.ID().getText())
    #     if ctx.arguments():
    #         self.result_buffer += ctx.arguments().getText()
    #     self.result_buffer += ') {\n'
    #     self.visit(ctx.function_body())
    #     self.result_buffer += '}\n\n'
    #
    def visitAssignment(self, ctx):
        self.vars[ctx.ID().getText()] = self.visit(ctx.expr())
    #
    # def visitFunc_stat(self, ctx):
    #     self.result_buffer += '\t'
    #     super(ToJSVisitor, self).visitFunc_stat(ctx)
    #
    # def visitReturn_stat(self, ctx):
    #     self.result_buffer += 'return '
    #     self.visit(ctx.expr())
    #     self.result_buffer += ';\n'

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
    #
    # def visitFuncCallAtom(self, ctx):
    #     self.result_buffer += ctx.getText()
    #

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
    #
    # def visitFor_stat(self, ctx):
    #     self.result_buffer += "for (var {it} = 0; i < {range}; i++) {{\n".format(it=ctx.ID().getText(),
    #                                                                              range=ctx.INT().getText())
    #     self.visit(ctx.for_body())
    #     self.result_buffer += "}\n"
