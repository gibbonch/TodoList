protocol TodoEditorInteractorInput: AnyObject {
    
    func updateTitle(_ title: String)
    func updateTask(_ task: String)
    func saveTask()
    func moveToPreviousSnapshot()
    func moveToNextSnapshot()
}

protocol TodoEditorInteractorOutput: AnyObject {
    
    func todoChanged(title: String, task: String)
    func historyStatusChanged(_ status: HistoryStatus)
}
