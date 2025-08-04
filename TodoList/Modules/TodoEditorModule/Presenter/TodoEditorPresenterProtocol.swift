protocol TodoEditorPresenterProtocol: AnyObject {
    
    func viewLoaded()
    func viewWillDisappear()
    func titleChanged(_ title: String)
    func taskChanged(_ task: String)
    func previousTapped()
    func nextTapped()
}
