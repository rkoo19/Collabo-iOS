import SwiftUI
import Firebase

class PostViewModel : ObservableObject{
    
    @Published var Projects : [PostModel] = []
    @Published var noProjects = false
    @Published var newPost = false
    @Published var updateId = ""
    @Published var savedStatus = false
    @Published var appliedTo = false
    @Published var group_array = [String]()
    @Published var group_array_2 = [String]()
    @Published var uid = Auth.auth().currentUser!.uid
    
    init() {
        
        getAllProjects()
    }
    
    func getAllProjects(){
        
        ref.collection("Projects").addSnapshotListener { (snap, err) in
            guard let docs = snap else{
                self.noProjects = true
                return
            }
            
            if docs.documentChanges.isEmpty{
                
                self.noProjects = true
                return
            }
            
            docs.documentChanges.forEach { (doc) in
                
                // Checking If Doc Added...
                if doc.type == .added{
                    
                    // Retreving And Appending...
                    
                    let title = doc.document.data()["title"] as! String
                    let category = doc.document.data()["category"] as! String
                    let time = doc.document.data()["time"] as! Timestamp
                    let pic = doc.document.data()["url"] as! String
                    let userRef = doc.document.data()["ref"] as! DocumentReference
                    let userString = doc.document.data()["userString"] as! String
                    let appliedBy = doc.document.data()["appliedBy"] as! Array<String>
                    let positionWanted = doc.document.data()["positionWanted"] as! Array<String>
                    
                    // getting user Data...
                    
                    fetchUser(uid: userRef.documentID) { (user) in
                        
                        self.Projects.append(PostModel(id: doc.document.documentID, title: title, category: category, pic: pic, time: time.dateValue(), user: user, userString: userString, appliedBy: appliedBy, positionWanted: positionWanted))
                        // Sorting All Model..
                        // you can also doi while reading docs...
                        self.Projects.sort { (p1, p2) -> Bool in
                            return p1.time > p2.time
                        }
                    }
                }
                
                // removing post when deleted...
                
                if doc.type == .removed{
                    
                    let id = doc.document.documentID
                    
                    self.Projects.removeAll { (post) -> Bool in
                        return post.id == id
                    }
                }
                
                if doc.type == .modified{
                    
                    // firebase is firing modifed when a new doc writed
                    // I dont know Why may be its bug...
                    print("Updated...")
                    // Updating Doc...
                    
                    let id = doc.document.documentID
                    let title = doc.document.data()["title"] as! String
                    //let category = doc.document.data()["category"] as! String
                    
                    let index = self.Projects.firstIndex { (post) -> Bool in
                        return post.id == id
                    } ?? -1
                    
                    // safe Check...
                    // since we have safe check so no worry
                    
                    if index != -1{
                        
                        self.Projects[index].title = title
                        //self.Projects[index].category = category
                        self.updateId = ""
                    }
                }
            }
        }
    }
    
    // deleting Projects...
    
    func deletePost(id: String){
        
        // 12.28: Deletes instance of postid from every user's savedPosts array.
        ref.collection("Users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                // Some error occured
                print(err.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    document.reference.updateData([
                        "savedPosts": FieldValue.arrayRemove([id])
                    ])
                }
            }
        }
        
        ref.collection("Projects").document(id).delete { (err) in
            if err != nil{
                print(err!.localizedDescription)
                return
            }
        }

    }
    
    func editPost(id: String){
        
        updateId = id
        // Poping New Post Screen
        newPost.toggle()
    }
    
    // 12.24. Save Post
    
    func savePost(id: String){
        
        let uid = Auth.auth().currentUser!.uid
        let temp = ref.collection("Users").document(uid)

        // Atomically add a new region to the "regions" array field.
        temp.updateData([
            "savedPosts": FieldValue.arrayUnion([id])
        ])
        
        savedStatus = !savedStatus
        
    }
    
    // 12.25 Un-Save Post
    
    func unsavePost(id: String){
        
        let uid = Auth.auth().currentUser!.uid
        let temp = ref.collection("Users").document(uid)

        temp.updateData([
            "savedPosts": FieldValue.arrayRemove([id])
        ])
        
        savedStatus = !savedStatus
        
    }
    
    func savedContains(id: String) -> Bool { // view
        
        let uid = Auth.auth().currentUser!.uid
        
        Firestore.firestore().collection("Users").document(uid).getDocument {
            (document, error) in
            if let document = document {
                self.group_array = document["savedPosts"] as? Array ?? [""]
            }
        }
        
        print(self.group_array)
        
        if self.group_array.contains(id) {
            return true
        } else {
            return false
        }
        
    }
    
    func getSaved() -> Array<String> {
        
        let uid = Auth.auth().currentUser!.uid
        
        Firestore.firestore().collection("Users").document(uid).getDocument {
            (document, error) in
            if let document = document {
                self.group_array = document["savedPosts"] as? Array ?? [""]
            }
        }
        return self.group_array
    }
    
    func applyTo (id: String) {

        let uid = Auth.auth().currentUser!.uid

        let temp = ref.collection("Projects").document(id)

        temp.updateData([
            "appliedBy": FieldValue.arrayUnion([uid])
        ])

        appliedTo = !appliedTo

    }
    
    func undoApply (id: String) {
        
        let uid = Auth.auth().currentUser!.uid

        let temp = ref.collection("Projects").document(id)

        temp.updateData([
            "appliedBy": FieldValue.arrayRemove([uid])
        ])

        appliedTo = !appliedTo
        
        
    }
    
    func appliedByContains(id: String) -> Bool { // view
        
        let uid = Auth.auth().currentUser!.uid
        
        Firestore.firestore().collection("Projects").document(id).getDocument {
            (document, error) in
            if let document = document {
                self.group_array_2 = document["appliedBy"] as? Array ?? [""]
            }
        }
        
        if self.group_array_2.contains(uid) {
            return true
        } else {
            return false
        }
        
    }

//    func getReachOut(id: String) {
//
//        let uid = Auth.auth().currentUser!.uid
//
//        Firestore.firestore().collection("Projects").document(uid).getDocument {
//            (document, error) in
//            let appliedBy = document?.get("appliedBy") as? Array<String>
//
//
//    }
//    }


        
    
}

