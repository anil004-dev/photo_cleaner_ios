//
//  BackupContactView.swift
//  CleanerApp
//
//  Created by iMac on 15/12/25.
//

import SwiftUI

struct BackupContactView: View {
    
    @StateObject var viewModel = BackupContactViewModel()
    
    var body: some View {
        ZStack {
            LinearGradient.blueBg.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                backupContactSection
            }
        }
        .navigationTitle("Backups")
        .navigationBarTitleDisplayMode(.inline)
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
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack { }.frame(height: 5)
                        
                        ForEach(arrBackups) { backup in
                            backupRow(
                                backup: backup,
                                onTap: {
                                    viewModel.btnBackupRowAction(backup: backup)
                                }
                            )
                        }
                        
                        VStack { }.frame(height: 20)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

extension BackupContactView {
    
    @ViewBuilder
    private func backupRow(backup: BackupModel, onTap: @escaping (() -> Void)) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 20) {
                    CNText(title: backup.name, color: .white, font: .system(size: 17, weight: .semibold, design: .default))
                    
                    Spacer(minLength: 0)
                    
                    Image(systemName: "square.and.arrow.up")
                        .resizable()
                        .scaledToFit()
                        .fontWeight(.semibold)
                        .frame(width: 22, height: 22)
                }
            }
            .padding(15)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.darkBlueCellBg)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
            onTap()
        }
    }
}
