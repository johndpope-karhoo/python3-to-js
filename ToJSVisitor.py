from gen.Python3Visitor import Python3Visitor


class ToJSVisitor(Python3Visitor):
    def __init__(self):
        super(ToJSVisitor, self).__init__()
        self.result_buffer = ""

    def visitPrint(self, ctx):
        self.result_buffer += 'console.log({ctx});\n'.format(ctx=ctx.expr().getText())

    def visitFunction_def(self, ctx):
        import ipdb; ipdb.set_trace()