//
//  ContactDatabase.swift
//  CleanerApp
//
//  Created by iMac on 09/12/25.
//

import Contacts
import ContactsUI

// MARK: - Main Database
class ContactDatabase {
    
    static let shared = ContactDatabase()
    private let store = CNContactStore()
    
    private init() {}
    
    // MARK: - Fetch ALL Contacts
    func fetchAllContacts() async throws -> [ContactModel] {
        return try await Task.detached(priority: .high) { () -> [ContactModel] in
            
            /*let keys: [CNKeyDescriptor] = [
                CNContactIdentifierKey as CNKeyDescriptor,
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactMiddleNameKey as CNKeyDescriptor,
                CNContactNicknameKey as CNKeyDescriptor,
                CNContactOrganizationNameKey as CNKeyDescriptor,
                
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactEmailAddressesKey as CNKeyDescriptor,
                CNContactPostalAddressesKey as CNKeyDescriptor,
                CNContactBirthdayKey as CNKeyDescriptor,
                CNContactDatesKey as CNKeyDescriptor,
                
                CNContactImageDataKey as CNKeyDescriptor,
                CNContactThumbnailImageDataKey as CNKeyDescriptor,
            ]*/
            
            let keys = [CNContactVCardSerialization.descriptorForRequiredKeys()]
            let request = CNContactFetchRequest(keysToFetch: keys)
            var result: [ContactModel] = []
            
            try await self.store.enumerateContacts(with: request) { contact, _ in
                let fullName = [contact.givenName, contact.middleName, contact.familyName]
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
                .joined(separator: " ")
                
                let displayName = fullName.isEmpty ? nil : fullName
                
                result.append(
                    ContactModel(
                        id: contact.identifier,
                        displayName: displayName,
                        givenName: contact.givenName,
                        familyName: contact.familyName,
                        phoneNumbers: contact.phoneNumbers.map { $0.value.stringValue },
                        emailAddresses: contact.emailAddresses.map { ($0.value as String) },
                        raw: contact
                    )
                )
            }
            
            return result
        }.value
    }
    
    func fetchFreshContact(using id: String) throws -> ContactModel {
        let keys = [CNContactViewController.descriptorForRequiredKeys()]
        let contact = try store.unifiedContact(withIdentifier: id, keysToFetch: keys)
        let fullName = [contact.givenName, contact.middleName, contact.familyName]
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        let displayName = fullName.isEmpty ? nil : fullName

        return ContactModel(
            id: contact.identifier,
            displayName: displayName,
            givenName: contact.givenName,
            familyName: contact.familyName,
            phoneNumbers: contact.phoneNumbers.map { $0.value.stringValue },
            emailAddresses: contact.emailAddresses.map { $0.value as String },
            raw: contact
        )
    }
    
    func buildDuplicateModel(from contacts: [ContactModel]) -> DuplicateContactModel {
        let nameGroups = findDuplicateNames(in: contacts).map { ContactGroup(arrContacts: $0) }
        let duplicateName = DuplicateContact(type: .duplicateName, arrContactGroup: nameGroups)
        let phoneGroups = findDuplicatePhones(in: contacts).map { ContactGroup(arrContacts: $0) }
        let duplicateNumber = DuplicateContact(type: .duplicateNumber, arrContactGroup: phoneGroups)
        let emailGroups = findDuplicateEmails(in: contacts).map { ContactGroup(arrContacts: $0) }
        let duplicateEmail = DuplicateContact(type: .duplicateEmail, arrContactGroup: emailGroups)

        return DuplicateContactModel(
            arrDuplicateName: duplicateName,
            arrDuplicateNumber: duplicateNumber,
            arrDuplicateEmail: duplicateEmail
        )
    }

    func buildIncompleteModel(from contacts: [ContactModel]) -> IncompleteContactModel {
        
        // 1. No Name
        let noName = noNameContacts(contacts)
        let nameGroups = noName.map { ContactGroup(arrContacts: [$0]) }
        let incompleteName = IncompleteContact(type: .noName, arrContactGroup: nameGroups)
        
        // 2. No Number
        let noNumber = noPhoneContacts(contacts)
        let numberGroups = noNumber.map { ContactGroup(arrContacts: [$0]) }
        let incompleteNumber = IncompleteContact(type: .noNumber, arrContactGroup: numberGroups)
        
        // 3. No Email
        let noEmail = noEmailContacts(contacts)
        let emailGroups = noEmail.map { ContactGroup(arrContacts: [$0]) }
        let incompleteEmail = IncompleteContact(type: .noEmail, arrContactGroup: emailGroups)
        
        return IncompleteContactModel(
            arrNoName: incompleteName,
            arrNoNumber: incompleteNumber,
            arrNoEmail: incompleteEmail
        )
    }
    
    func buildMergedPreview(for group: ContactGroup) -> CNMutableContact {
        let contacts = group.arrContacts
        guard let first = contacts.first else {
            return CNMutableContact()
        }
        
        let merged = CNMutableContact()
        
        // MARK: Name from first contact
        merged.givenName = first.givenName
        merged.familyName = first.familyName
        merged.middleName = first.raw.middleName
        merged.nickname = first.raw.nickname
        merged.organizationName = first.raw.organizationName
        
        // MARK: Merge phones
        let allPhones = contacts
            .flatMap { $0.raw.phoneNumbers }
            .map { $0.value.stringValue }
        
        let uniquePhones = Array(Set(allPhones)).sorted()
        
        merged.phoneNumbers = uniquePhones.map {
            let label = CNLabelPhoneNumberMobile
            return CNLabeledValue(label: label, value: CNPhoneNumber(stringValue: $0))
        }
        
        // MARK: Merge emails
        let allEmails = contacts
            .flatMap { $0.raw.emailAddresses }
            .map { ($0.value as String) }
        
        let uniqueEmails = Array(Set(allEmails)).sorted()
        
        merged.emailAddresses = uniqueEmails.map {
            CNLabeledValue(label: CNLabelHome, value: $0 as NSString)
        }
        
        // MARK: Postal addresses
        let allAddresses = contacts.flatMap { $0.raw.postalAddresses }
        merged.postalAddresses = uniqueLabeledAddresses(allAddresses)
        
        // MARK: Birthday (take first valid)
        for c in contacts {
            if let b = c.raw.birthday {
                merged.birthday = b
                break
            }
        }
        
        return merged
    }
    
    // MARK: - Backup (VCF)
    private func backupDirectoryURL() throws -> URL {
        let documentsURL = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        
        let backupURL = documentsURL.appendingPathComponent("Contacts_backup", isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: backupURL.path) {
            try FileManager.default.createDirectory(
                at: backupURL,
                withIntermediateDirectories: true
            )
        }
        
        return backupURL
    }

    private func backupFileName() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd_MMM_yyyy_hh_mm_ss_a"
        
        let dateString = formatter.string(from: Date()).lowercased()
        return "contact_backup_\(dateString).vcf"
    }

    
    // MARK: - Backup (VCF)
    func generateVCF() async -> (url: URL?, error: String?) {
        do {
            let cnContacts = try await fetchAllContacts().map { $0.raw }
            
            guard !cnContacts.isEmpty else {
                return (
                    nil,
                    "No contacts available to back up. Please make sure you have at least one contact saved."
                )
            }
            
            let vcardData = try CNContactVCardSerialization.data(with: cnContacts)
            
            let fileName = backupFileName()
            let backupDirectory = try backupDirectoryURL()
            let fileURL = backupDirectory.appendingPathComponent(fileName)
            
            try vcardData.write(to: fileURL, options: [.atomicWrite])
            return (fileURL, nil)
            
        } catch let error as NSError {
            // Debug log (keep technical details out of UI)
            print("❌ VCF generation failed:", error)
            
            // User-friendly messages
            if error.domain == CNErrorDomain {
                return (
                    nil,
                    "Contacts access is not available. Please allow contact access in Settings and try again."
                )
            }
            
            if error.domain == NSCocoaErrorDomain {
                return (
                    nil,
                    "Unable to save the backup file. Please make sure there is enough storage space on your device."
                )
            }
            
            return (
                nil,
                "Something went wrong while creating the backup. Please try again."
            )
        }
    }
    func fetchBackups() -> [BackupModel] {
        do {
            let backupDirectory = try backupDirectoryURL()
            
            let files = try FileManager.default.contentsOfDirectory(
                at: backupDirectory,
                includingPropertiesForKeys: [.creationDateKey],
                options: [.skipsHiddenFiles]
            )
            
            return files
                .filter { $0.pathExtension.lowercased() == "vcf" }
                .sorted {
                    let date1 = (try? $0.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
                    let date2 = (try? $1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
                    return date1 > date2
                }
                .map {
                    BackupModel(
                        name: $0.lastPathComponent,
                        url: $0
                    )
                }
            
        } catch {
            print("❌ Failed to fetch backups:", error)
            return []
        }
    }
}

extension ContactDatabase {
    
    func mergeAll(groups: [ContactGroup]) async throws {
        let saveRequest = CNSaveRequest()
        
        for group in groups {
            let merged = buildMergedPreview(for: group)
            saveRequest.add(merged, toContainerWithIdentifier: nil)
            
            // delete old ones
            for model in group.arrContacts {
                let mutable = model.raw.mutableCopy() as! CNMutableContact
                saveRequest.delete(mutable)
            }
        }
        
        try store.execute(saveRequest)
    }
    
    func deleteContact(contact: ContactModel) -> Bool {
        let store = CNContactStore()
        
        do {
            // Make mutable copy from the raw CNContact
            let mutable = contact.raw.mutableCopy() as! CNMutableContact
            
            // Build save request
            let request = CNSaveRequest()
            request.delete(mutable)
            
            // Execute delete
            try store.execute(request)
            
            return true
        } catch {
            return false
        }
    }

    func saveEditedContact(_ model: ContactModel) throws {
        let mutable = model.raw.mutableCopy() as! CNMutableContact
        
        // Update names
        mutable.givenName = model.givenName
        mutable.familyName = model.familyName
        
        // ---- FIX: Keep identifiers when updating phone numbers ----
        var newPhones: [CNLabeledValue<CNPhoneNumber>] = []
        
        for (index, phone) in model.phoneNumbers.enumerated() {
            let value = CNPhoneNumber(stringValue: phone)
            
            if index < mutable.phoneNumbers.count {
                // update existing labeled value (keep identifier!)
                let old = mutable.phoneNumbers[index]
                let updated = old.settingValue(value)
                newPhones.append(updated)
            } else {
                // create new labeled value
                let new = CNLabeledValue(
                    label: CNLabelPhoneNumberMobile,
                    value: value
                )
                newPhones.append(new)
            }
        }
        
        mutable.phoneNumbers = newPhones
        
        // ---- FIX: Same for email addresses ----
        var newEmails: [CNLabeledValue<NSString>] = []
        
        for (index, email) in model.emailAddresses.enumerated() {
            let value = email as NSString
            
            if index < mutable.emailAddresses.count {
                let old = mutable.emailAddresses[index]
                let updated = old.settingValue(value)
                newEmails.append(updated)
            } else {
                let new = CNLabeledValue(label: CNLabelHome, value: value)
                newEmails.append(new)
            }
        }
        
        mutable.emailAddresses = newEmails
        
        // Save request
        let req = CNSaveRequest()
        req.update(mutable)
        
        try store.execute(req)
    }

    func uniqueLabeledAddresses(_ addresses: [CNLabeledValue<CNPostalAddress>])
    -> [CNLabeledValue<CNPostalAddress>] {

        var set = Set<String>()   // stringify to detect duplicates
        var result: [CNLabeledValue<CNPostalAddress>] = []

        for item in addresses {
            let s = item.value.street +
                    "|" + item.value.city +
                    "|" + item.value.state +
                    "|" + item.value.postalCode +
                    "|" + item.value.country

            if !set.contains(s) {
                set.insert(s)
                result.append(item)
            }
        }

        return result
    }

    
    // MARK: - Duplicate Detection
    
    /// 1. Duplicate Names
    func findDuplicateNames(in list: [ContactModel]) -> [[ContactModel]] {

        // Step 1: Build groups by FULL EXACT NAME
        var map = [String: [ContactModel]]()
        
        for c in list {

            // Build full name using all components (you asked for this)
            let fullName = [
                c.givenName,
                c.raw.middleName,
                c.familyName
            ]
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

            if fullName.isEmpty { continue }

            // EXACT match key (case-insensitive only)
            let key = fullName.lowercased()

            map[key, default: []].append(c)
        }

        // Step 2: filter groups
        return map.values.filter { group in

            // Must have more than one
            guard group.count > 1 else { return false }

            // ❗ RULE: Every contact in the group must have phone numbers
            for c in group {
                if c.phoneNumbers.isEmpty {
                    return false // discard whole group
                }
            }

            return true
        }
    }

    /// 2. Duplicate Phones
    func findDuplicatePhones(in list: [ContactModel]) -> [[ContactModel]] {
        var phoneMap = [String: Set<ContactModel>]()
        
        for c in list {
            for phone in c.phoneNumbers {
                if phone.isEmpty { continue }
                
                phoneMap[phone.normalizedPhone(), default: []].insert(c)
            }
        }
        
        return phoneMap.values
            .map { Array($0) }
            .filter { $0.count > 1 }
    }

    
    /// 3. Duplicate Emails
    func findDuplicateEmails(in list: [ContactModel]) -> [[ContactModel]] {
        var emailMap = [String: Set<ContactModel>]()
        
        for c in list {
            for email in c.emailAddresses {
                if email.isEmpty { continue }
                emailMap[email, default: []].insert(c)
            }
        }
        
        return emailMap.values
            .map { Array($0) }
            .filter { $0.count > 1 }
    }
    
    // MARK: - Incomplete Contacts
    
    func noNameContacts(_ list: [ContactModel]) -> [ContactModel] {
        list.filter { $0.isNoName }
    }
    
    func noPhoneContacts(_ list: [ContactModel]) -> [ContactModel] {
        list.filter { $0.isNoPhone }
    }
    
    func noEmailContacts(_ list: [ContactModel]) -> [ContactModel] {
        list.filter { $0.isNoEmail }
    }
    
    func noPhoneAndEmailContacts(_ list: [ContactModel]) -> [ContactModel] {
        list.filter { $0.isNoPhone && $0.isNoEmail }
    }
    
    // MARK: - Levenshtein Distance
    
    private func levenshteinDistance(_ a: String, _ b: String) -> Int {
        let aChars = Array(a.lowercased())
        let bChars = Array(b.lowercased())
        
        var dist = Array(
            repeating: Array(repeating: 0, count: bChars.count + 1),
            count: aChars.count + 1
        )
        
        for i in 0...aChars.count { dist[i][0] = i }
        for j in 0...bChars.count { dist[0][j] = j }
        
        for i in 1...aChars.count {
            for j in 1...bChars.count {
                let cost = aChars[i-1] == bChars[j-1] ? 0 : 1
                
                dist[i][j] = min(
                    dist[i-1][j] + 1,
                    dist[i][j-1] + 1,
                    dist[i-1][j-1] + cost
                )
            }
        }
        
        return dist[aChars.count][bChars.count]
    }
}
