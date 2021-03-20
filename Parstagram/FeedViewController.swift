//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Kristy Lau on 3/12/21.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {

    @IBOutlet var tableView: UITableView!
    
    // Create instance of MessageInputBar
    let commentBar = MessageInputBar()
    
    var showsCommentBar = false
    
    // Create an array of posts
    var posts = [PFObject]()
    
    var selectedPost: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Allows keyboard to be dismissed by dragging down on tableView
        tableView.keyboardDismissMode = .interactive
        
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    
    @objc func keyboardWillBeHidden(note: Notification) {
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Make query (parse)
        
        let query = PFQuery(className:"Posts")
        
        // Additional options
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in
            // If we were able to find some stuff
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // Create the comment
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!
        
        selectedPost.add(comment, forKey: "comments")
        
        selectedPost.saveInBackground { (success, error) in
            if success {
                print("Comment saved")
            } else {
                print("Error saving comment")
            }
        }
        
        // For refreshing
        tableView.reloadData()
        
        // Clear and dismiss the input bar
        commentBar.inputTextView.text = nil
        
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        // whatever is on the left, if it is nill, set variable equal to whatever is on the right side (default value)
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        // +2 to include AddCommentCell
        return comments.count + 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            
     
            
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            
            
            // Set caption
            cell.captionLabel.text = post["caption"] as! String
            
            // To allow photo to load
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            cell.photoView.af_setImage(withURL: url)
            
            return cell
        } else if indexPath.row <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            // Show that comment array
            let comment = comments[indexPath.row - 1]
            
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            
            cell.nameLabel.text = user.username
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let post = posts[indexPath.section]
        
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        // Check for last cell and show that comment
        if indexPath.row == comments.count + 1 {
            // Show the comment bar
            showsCommentBar = true
            becomeFirstResponder()
            
            // Raise the keyboard
            commentBar.inputTextView.becomeFirstResponder()
            
            
            selectedPost = post
        }
        
        // We moved the portion below to messageInputBar
        /*
        comment["text"] = "This is a comment"
        comment["post"] = post
        comment["author"] = PFUser.current()!
        
        post.add(comment, forKey: "comments")
        
        post.saveInBackground { (success, error) in
            if success {
                print("Comment saved")
            } else {
                print("Error saving comment")
            }
        }
        */
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func onLogoutButton(_ sender: Any) {
        
        // Do the logout action
        // Clears Parse cache
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        // Instatiate to the login screen (LoginViewController)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        // one object that is exists for each application
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        
        delegate.window?.rootViewController = loginViewController
    }
    
}
