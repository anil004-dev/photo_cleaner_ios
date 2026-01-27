//
//  BackupContactView.swift
//  CleanerApp
//
//  Created by iMac on 15/12/25.
//

import SwiftUI

struct BackupContactView: View {
    
    @StateObject var viewModel = BackupContactViewModel()
    @Environment(\.modelContext) var context
    
    var body: some View {
        ZStack {
            Color.bgDarkBlue.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                backupContactSection
            }
        }
        .toolbar(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.prepareBackup()
                } label: {
                    CNNavButton(
                        imageName: "plus",
                        fontWeight: .medium,
                        iconColor: .white,
                        iconSize: CGSize(width: 20, height: 20),
                        backgroundColor: .clear,
                        isLeftButton: false
                    )
                }
            }
        }
        .onAppear {
            ContactBackupManager.shared.configure(with: context)
            viewModel.onAppear()
        }
        .sheet(isPresented: $viewModel.showShareSheet.sheet) {
            if let url = viewModel.showShareSheet.url {
                CNShareSheetView(items: [url])
                    .presentationDetents([.medium, .large])
            }
        }
    }
    
    private var backupContactSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            let arrBackups = viewModel.arrBackups
            
            if arrBackups.isEmpty {
                ContentUnavailableView(
                    "No Backups Yet",
                    systemImage: "tray",
                    description: Text("You haven’t created any contact backups yet. Tap Backup to create your first one.")
                )
            } else {
                backupListSection
            }
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            CNText(title: "Backups", color: .white, font: .system(size: 34, weight: .bold, design: .default), alignment: .trailing)
            
            CNText(title: "\(viewModel.arrBackups.count) Backup", color: .init(hex: "7E828B"), font: .system(size: 12, weight: .semibold, design: .default), alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }
    
    private var backupListSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleSection
                .padding(.bottom, 8)
            
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.arrBackups) { backup in
                        backupRow(backup: backup) {
                            viewModel.btnBackupRowAction(backup: backup)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
                .padding(.top, 14)
            }
        }
    }
}

extension BackupContactView {
    
    @ViewBuilder
    private func backupRow(backup: ContactBackupModel, onTap: @escaping (() -> Void)) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    CNText(title: backup.formattedDate, color: .white, font: .system(size: 17, weight: .medium, design: .default))
                    
                    CNText(title: "\(backup.contactCount) Contacts", color: Color(hex: "7F818D"), font: .system(size: 18, weight: .regular, design: .default))
                }
                
                Spacer(minLength: 0)
                
                Image(systemName: "chevron.forward")
                    .resizable()
                    .scaledToFit()
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "9395A2"))
                    .frame(width: 11, height: 16)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
        }
        .background(Color(hex: "191D2B"))
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .onTapGesture {
            onTap()
        }
    }
}
