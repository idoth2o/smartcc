#pragma once

#include <iostream>
#include <vector>
#include <llvm/IR/Value.h>

class CodeGenContext;
class NStatement;
class NExpression;
class NVariableDeclaration;

typedef std::vector<NStatement*> StatementList;
typedef std::vector<NExpression*> ExpressionList;
typedef std::vector<NVariableDeclaration*> VariableList;

class Node {
public:
	virtual ~Node() {}
	virtual llvm::Value* codeGen(CodeGenContext& context) { return NULL; }
};

class NExpression : public Node {
};

class NStatement : public Node {
};

class NBlock : public NExpression {
public:
	StatementList statements;
	NBlock() { }
	virtual llvm::Value* codeGen(CodeGenContext& context);
};

class NInteger : public NExpression {
public:
	long long value;
	NInteger(long long value) : value(value) { }
	virtual llvm::Value* codeGen(CodeGenContext& context);
};

class NIdentifier : public NExpression {
public:
	std::string name;
	NIdentifier(const std::string& name) : name(name) { }
	virtual llvm::Value* codeGen(CodeGenContext& context);
};

class NMethodCall : public NExpression {
public:
	const NIdentifier& id;
	ExpressionList arguments;
	NMethodCall(const NIdentifier& id, ExpressionList& arguments) :
		id(id), arguments(arguments) { }
	NMethodCall(const NIdentifier& id) : id(id) { }
	virtual llvm::Value* codeGen(CodeGenContext& context);
};

class NAssignment : public NExpression {
public:
        NIdentifier& lhs;
        NExpression& rhs;
        NAssignment(NIdentifier& lhs, NExpression& rhs) :
                lhs(lhs), rhs(rhs) { }
        virtual llvm::Value* codeGen(CodeGenContext& context);
};

class NExpressionStatement : public NStatement {
public:
        NExpression& expression;
        NExpressionStatement(NExpression& expression) :
                expression(expression) { }
        virtual llvm::Value* codeGen(CodeGenContext& context);
};

class NReturnStatement : public NStatement {
public:
        NExpression& expression;
        NReturnStatement(NExpression& expression) :
                expression(expression) { }
        virtual llvm::Value* codeGen(CodeGenContext& context);
};

class NVariableDeclaration : public NStatement {
public:
        const NIdentifier& type;
        NIdentifier& id;
        NExpression *assignmentExpr;
        NVariableDeclaration(const NIdentifier& type, NIdentifier& id) :
                type(type), id(id) { assignmentExpr = NULL; }
        NVariableDeclaration(const NIdentifier& type, NIdentifier& id, NExpression *assignmentExpr) :
                type(type), id(id), assignmentExpr(assignmentExpr) { }
        virtual llvm::Value* codeGen(CodeGenContext& context);
};
