protocol TodoEditorInteractorInput: AnyObject {
    
    func updateTitle(_ title: String)
    func updateTask(_ task: String)
    func saveTask()
    func moveToPreviousSnapshot()
    func moveToNextSnapshot()
}

protocol TodoEditorInteractorOutput: AnyObject {
    
    func validationStatusChanged(_ isValid: Bool)
    func todoChanged(title: String, task: String)
    func todoSaved()
    func historyStatusChanged(_ status: HistoryStatus)
}
