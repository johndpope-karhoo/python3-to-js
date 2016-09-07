from gen.Python3Visitor import Python3Visitor


class ToJSVisitor(Python3Visitor):
    def __init__(self):
        super(ToJSVisitor, self).__init__()
        self.result_buffer = ""

    def visitPrint(self, ctx):
        self.result_buffer += 'console.log({ctx});\n'.format(ctx=ctx.expr().getText())

    def visitFunction_def(self, ctx):
        self.result_buffer += '\nfunction {name}('.format(name=ctx.ID().getText())
        if ctx.arguments():
            self.result_buffer += ctx.arguments().getText()
        self.result_buffer += ') {\n'
        self.visit(ctx.function_body())
        self.result_buffer += '}\n\n'

    def visitAssignment(self, ctx):
        self.result_buffer += 'var {id} = '.format(id=ctx.ID().getText())
        self.visit(ctx.expr())
        self.result_buffer += ';\n'

    def visitFunc_stat(self, ctx):
        self.result_buffer += '\t'
        super(ToJSVisitor, self).visitFunc_stat(ctx)

    def visitReturn_stat(self, ctx):
        self.result_buffer += 'return '
        self.visit(ctx.expr())
        self.result_buffer += ';\n'

    def visitParAtom(self, ctx):
        self.result_buffer += '('
        self.visit(ctx.expr())
        self.result_buffer += ')'

    def visitNumberAtom(self, ctx):
        self.result_buffer += ctx.getText()

    def visitStringAtom(self, ctx):
        self.result_buffer += ctx.getText()

    def visitNilAtom(self, ctx):
        self.result_buffer += "null"

    def visitIdAtom(self, ctx):
        self.result_buffer += ctx.getText()

    def visitBooleanAtom(self, ctx):
        if ctx.TRUE():
            self.result_buffer += "true"
        elif ctx.FALSE():
            self.result_buffer += "false"

    def visitFuncCallAtom(self, ctx):
        self.result_buffer += ctx.getText()

    def visitNotExpr(self, ctx):
        self.result_buffer += '!'
        self.visit(ctx.expr())

    def visitMulExpr(self, ctx):
        self.result_buffer += ctx.getText()

    def visitAddExpr(self, ctx):
        self.result_buffer += ctx.getText()

    def visitMinusExpr(self, ctx):
        self.result_buffer += ctx.getText()
