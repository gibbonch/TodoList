protocol TodoEditorPresenterProtocol: AnyObject {
    
    func viewLoaded()
    func titleChanged(_ title: String)
    func taskChanged(_ task: String)
    func saveTapped()
    func previousTapped()
    func nextTapped()
    func allowsDismissing() -> Bool
}
