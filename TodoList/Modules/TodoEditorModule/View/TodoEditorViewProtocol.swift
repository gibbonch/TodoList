protocol TodoEditorViewProtocol: AnyObject {
    
    func updateState(with newState: TodoEditorViewState)
    func setTitle(_ title: String)
    func dismiss()
}
