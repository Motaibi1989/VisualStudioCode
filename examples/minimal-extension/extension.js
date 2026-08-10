const vscode = require('vscode');

function activate(context) {
    const command = vscode.commands.registerCommand(
        'myTools.showProjectInfo',
        () => {
            const editor = vscode.window.activeTextEditor;

            if (!editor) {
                vscode.window.showWarningMessage('No file is currently open.');
                return;
            }

            const document = editor.document;

            vscode.window.showInformationMessage(
                `File: ${document.fileName} | Language: ${document.languageId}`
            );
        }
    );

    context.subscriptions.push(command);
}

function deactivate() {}

module.exports = {
    activate,
    deactivate
};
