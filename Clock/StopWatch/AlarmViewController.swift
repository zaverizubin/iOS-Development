//
//  AlarmViewController.swift
//  StopWatch
//
//  Created by Mac Moham on 24/08/16.
//  Copyright © 2016 Focalworks. All rights reserved.
//

import UIKit

class AlarmViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var noAlarmsLabel: UILabel!
    
    @IBOutlet weak var alarmTableView: UITableView!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    let textCellIdentifier = "RowCell"
    
    let noAlarmsText = "No Alarms"
    
    var alarmModel:AlarmModel = AlarmModel()
    
    var selectedAlarmIndex:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let savedAlarms = loadAlarms() {
            AlarmModel.alarms = savedAlarms
        }
        alarmTableView.delegate = self
        alarmTableView.dataSource = self
        configureUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureUI(){
        toggleEditButton()
        self.tabBarItem.image = UIImage(named: "Alarm")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.tabBarItem.selectedImage = UIImage(named: "Alarm-down")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
    }

    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AlarmModel.alarms.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as! AlarmCustomRowCell
        
        let alarm = AlarmModel.alarms[indexPath.row]
        
        cell.timeLabel.text =  alarm.displayTime
        cell.amPMLabel.text =  alarm.isPM ? "PM":"AM"
        cell.alarmLabel.text = alarm.label
        cell.enableSwitch.on = true
        cell.tag = indexPath.row
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            AlarmModel.alarms.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            updateNoAlarmsText()
            saveAlarms()
        }
        toggleEditButton()
    }
    
    func toggleEditButton(){
        if(AlarmModel.alarms.count==0){
            editButton.enabled = false
            editButton.tintColor = UIColor.clearColor()
        }else{
            editButton.enabled = true
            editButton.tintColor = .None
        }
    }
    
    func dismissEditingMode(){
        alarmTableView.setEditing(false, animated: false)
        editButton.title = "Edit"
        toggleEditButton()

    }
   
    func updateNoAlarmsText()
    {
        noAlarmsLabel.text = AlarmModel.alarms.count>0 ? "" : noAlarmsText;
    }
    
    func saveAlarms(){
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(AlarmModel.alarms, toFile: Alarm.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save alarms...")
        }
    }
    
    func loadAlarms() -> [Alarm]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Alarm.ArchiveURL.path!) as? [Alarm]
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let destViewController = segue.destinationViewController as? UINavigationController{
            if let addAlarmViewController = (destViewController.topViewController as? AddAlarmViewController){
                if(segue.identifier == "editAlarmSegue"){
                    if let selectedIndex =  (alarmTableView.indexPathForSelectedRow?.row){
                        addAlarmViewController.alarm = AlarmModel.alarms[selectedIndex]
                    }
                }else if(segue.identifier == "createNewAlarmSegue"){
                    addAlarmViewController.alarm = Alarm()
                }
            }
        }
    }
    

    
    @IBAction func onEditButtonClick(sender: UIBarButtonItem) {
        if(sender.title!.lowercaseString == "edit"){
            alarmTableView.setEditing(true, animated: true)
            sender.title = "Done"
        }else{
            alarmTableView.setEditing(false, animated: true)
            sender.title = "Edit"
        }
        
    }
    
    
    @IBAction func cancelToAlarmViewController(segue:UIStoryboardSegue) {
        dismissEditingMode()
        saveAlarms()
        alarmTableView.reloadData()
    }
    
    @IBAction func saveToAlarmViewController(segue:UIStoryboardSegue) {
        dismissEditingMode()
        
        if segue.sourceViewController is AddAlarmViewController {
            updateNoAlarmsText()
            alarmTableView.reloadData()
        }
        saveAlarms()
    }
    
    
    
    
    
}